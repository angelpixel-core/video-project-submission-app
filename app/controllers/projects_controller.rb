class ProjectsController < ApplicationController
  before_action :load_project, only: %i[edit update]
  before_action :ensure_draft_project, only: %i[edit update]
  before_action :load_workspace_project, only: %i[accept complete]
  before_action :load_video_types, only: %i[edit update]

  def index
    status_order = Arel.sql("CASE status WHEN 'draft' THEN 0 WHEN 'pending' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'completed' THEN 3 ELSE 4 END")

    @projects = workspace_for(:client).projects.includes(video_type_selections: :video_type).order(status_order, created_at: :desc)

    @workspace_table_query = ::Projects::ListingQuery.new(params)
    @workspace_sort = @workspace_table_query.sort.presence || "created_at"
    @workspace_direction = @workspace_table_query.direction.presence || "desc"
    @workspace_page = @workspace_table_query.page
    @workspace_total_pages = @workspace_table_query.total_pages
    @workspace_projects = @workspace_table_query.call
  end

  def show
    @project = Project.includes(:owner, :participant, comments: :author_account, video_type_selections: :video_type).find(params[:id])
    @payments = @project.payments.includes(:payment_attempts).order(created_at: :desc)
    @comments = @project.comments.chronological.includes(:author_account)
    @comment = Comment.new
  end

  def new
    client_workspace = workspace_for(:client)
    pm_workspace = workspace_for(:pm)
    result = Projects::Application::Commands::CreateDraftProject.call(client_workspace: client_workspace, pm_workspace: pm_workspace)
    project = result.data.fetch(:project)

    redirect_to edit_project_path(project)
  end

  def edit
    @selections_json = selections_json_for(@project)
  end

  def update
    selections = parsed_selections

    if finalize_submission?
      result = Projects::Application::Commands::SubmitProject.call(
        project: @project,
        participant: workspace_for(:pm),
        attributes: project_attributes,
        selections: selections
      )

      if result.success?
        redirect_to projects_path, notice: "Project submitted for review."
      else
        @project.errors.add(:base, result.message) if @project.errors.empty?
        @selections_json = selections_json_for(@project)
        render :edit, status: :unprocessable_content
      end
    else
      result = Projects::Application::Commands::AutosaveDraftProject.call(
        project: @project,
        participant: workspace_for(:pm),
        attributes: project_attributes,
        selections: selections
      )

      if result.success?
        head :no_content
      else
        @project.errors.add(:base, result.message) if @project.errors.empty?
        @selections_json = selections_json_for(@project)
        render :edit, status: :unprocessable_content
      end
    end
  rescue ActiveRecord::RecordInvalid, ArgumentError, JSON::ParserError, ActionController::ParameterMissing => e
    @project.errors.add(:base, e.message) if @project.errors.empty?
    @selections_json = selections_json_for(@project)
    render :edit, status: :unprocessable_content
  end

  private

  def load_project
    @project = workspace_for(:client).projects.includes(video_type_selections: :video_type).find(params[:id])
  end

  def project_attributes
    params.require(:project).permit(:name, :raw_footage_url)
  end

  def parsed_selections
    raw = params.dig(:project, :selections_json)
    return [] if raw.blank?

    data = JSON.parse(raw, symbolize_names: true)
    data.filter_map do |selection|
      video_type_id = selection[:video_type_id].to_i
      quantity = selection[:quantity].to_i
      next if video_type_id <= 0 || quantity <= 0

      { video_type_id: video_type_id, quantity: quantity }
    end
  end

  def selections_json_for(project)
    project.video_type_selections.includes(:video_type).map do |selection|
      {
        video_type_id: selection.video_type_id,
        video_type_name: selection.video_type.name,
        price_cents: selection.video_type.price_cents,
        quantity: selection.quantity
      }
    end.to_json
  end

  def finalize_submission?
    params.dig(:project, :finalize) == "1"
  end

  public

  def accept
    process_workspace_action(
      event: :accept,
      success_notice: "Project accepted.",
      stale_alert: "Only pending projects can be accepted."
    )
  end

  def complete
    process_workspace_action(
      event: :complete,
      success_notice: "Project completed.",
      stale_alert: "Only in-progress projects can be completed."
    )
  end

  private

  def process_workspace_action(event:, success_notice:, stale_alert:)
    result = Projects::ActionService.call(project: @workspace_project, event: event)

    if result.success?
      respond_workspace_action_success(success_notice)
      Notification.broadcast_refresh_for(@workspace_project.participant) if result.data.fetch(:broadcast_refresh, false)
    else
      respond_workspace_action_stale(stale_alert)
    end
  end

  def respond_workspace_action_success(success_notice)
    if workspace_async_action_request?
      render json: workspace_row_action_payload
    else
      redirect_to projects_path, notice: success_notice
    end
  end

  def respond_workspace_action_stale(stale_alert)
    if workspace_async_action_request?
      head :conflict
    else
      redirect_to projects_path, alert: stale_alert
    end
  end

  def workspace_async_action_request?
    request.headers["X-Workspace-Async-Action"] == "1"
  end

  def sync_project_selections(project, selections)
    project.video_type_selections.delete_all

    selections.each do |selection|
      project.video_type_selections.create!(
        video_type_id: selection.fetch(:video_type_id),
        quantity: selection.fetch(:quantity)
      )
    end
  end

  def load_video_types
    @video_types = Catalog::Application::Queries::ListPublicVideoTypes.call(account: workspace_for(:client)).data.fetch(:video_types)
  end

  def ensure_draft_project
    return if @project.draft?

    redirect_to projects_path, alert: "Only draft projects can be edited."
  end

  def load_workspace_project
    @workspace_project = workspace_for(:pm).projects.find(params[:id])
  end

  def workspace_row_action_payload
    {
      project_id: @workspace_project.id,
      status_badge_text: @workspace_project.status_badge_text,
      status_badge_class: @workspace_project.status_badge_class,
      action: @workspace_project.pending? ? "complete" : (@workspace_project.in_progress? ? "complete" : nil)
    }
  end
end
