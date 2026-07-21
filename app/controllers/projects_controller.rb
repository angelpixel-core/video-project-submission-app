class ProjectsController < ApplicationController
  before_action :load_project, only: %i[edit update]
  before_action :ensure_draft_project, only: %i[edit update]
  before_action :load_pm_project, only: %i[accept complete]
  before_action :load_video_types, only: %i[edit update]

  def index
    status_order = Arel.sql("CASE status WHEN 'draft' THEN 0 WHEN 'pending' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'completed' THEN 3 ELSE 4 END")

    @projects = current_client.projects.includes(video_type_selections: :video_type).order(status_order, created_at: :desc)

    pm_table_params = ::PMProjectsTableParams.new(params)
    @pm_sort = pm_table_params.sort.presence || "created_at"
    @pm_direction = pm_table_params.direction.presence || "desc"
    @pm_page = pm_table_params.page
    @pm_table_query = ::PMTableQuery.new(sort: @pm_sort, direction: @pm_direction, page: @pm_page, per_page: 10)
    @pm_total_pages = @pm_table_query.total_pages
    @pm_projects = @pm_table_query.call
  end

  def show
    @project = Project.includes(:client, :pm, comments: :author, video_type_selections: :video_type).find(params[:id])
    @comments = @project.comments.chronological.includes(:author)
    @comment = Comment.new
  end

  def new
    project = current_client.projects.draft.order(created_at: :desc).first || current_client.projects.create!(pm: default_pm, status: :draft)
    redirect_to edit_project_path(project)
  end

  def edit
    @selections_json = selections_json_for(@project)
  end

  def update
    selections = parsed_selections

    if finalize_submission?
      finalize_project!(selections)
      NotificationJob.perform_later(@project.id)
      redirect_to projects_path, notice: "Project submitted for review."
    else
      autosave_project!(selections)
      head :no_content
    end
  rescue ActiveRecord::RecordInvalid, ArgumentError, JSON::ParserError, ActionController::ParameterMissing => e
    @project.errors.add(:base, e.message) if @project.errors.empty?
    @selections_json = selections_json_for(@project)
    render :edit, status: :unprocessable_content
  end

  private

  def load_project
    @project = current_client.projects.includes(video_type_selections: :video_type).find(params[:id])
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

  def autosave_project!(selections)
    Project.transaction do
      @project.assign_attributes(project_attributes)
      @project.pm ||= default_pm
      @project.status = :draft
      @project.save!
      sync_project_selections(@project, selections)
    end
  end

  def finalize_project!(selections)
    if selections.empty?
      @project.errors.add(:base, "Add at least one video type")
      raise ActiveRecord::RecordInvalid, @project
    end

    Project.transaction do
      @project.assign_attributes(project_attributes)
      @project.pm = default_pm
      @project.submit!
      sync_project_selections(@project, selections)
      payment_result = Payments::CreateOrReuseActivePayment.(project: @project)

      if payment_result.failure?
        @project.errors.add(:base, payment_result.message)
        raise ActiveRecord::RecordInvalid, @project
      end
    end
  end

  public

  def accept
    success = perform_pm_row_action(
      event: :accept,
      success_notice: "Project accepted.",
      stale_alert: "Only pending projects can be accepted."
    ) do
      @pm_project.accept!
      @pm_project.notifications.unread.update_all(read_at: Time.current)
      create_client_status_notification!(
        kind: "project_accepted",
        body: "Your project #{@pm_project.name.presence || 'Untitled project'} was accepted and is now in progress."
      )
    end

    Notification.broadcast_refresh_for(@pm_project.pm) if success
  end

  def complete
    perform_pm_row_action(
      event: :complete,
      success_notice: "Project completed.",
      stale_alert: "Only in-progress projects can be completed."
    ) do
      @pm_project.complete!
      create_client_status_notification!(
        kind: "project_completed",
        body: "Your project #{@pm_project.name.presence || 'Untitled project'} has been completed."
      )
    end
  end

  private

  def perform_pm_row_action(event:, success_notice:, stale_alert:)
    success = false

    @pm_project.with_lock do
      unless @pm_project.public_send("may_#{event}?")
        respond_pm_row_action_stale(stale_alert)
        next
      end

      yield
      success = true
    end

    return false unless success

    respond_pm_row_action_success(success_notice)
    true
  rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid
    respond_pm_row_action_stale(stale_alert)
    false
  end

  def respond_pm_row_action_success(success_notice)
    if pm_async_action_request?
      head :no_content
    else
      redirect_to projects_path, notice: success_notice
    end
  end

  def respond_pm_row_action_stale(stale_alert)
    if pm_async_action_request?
      head :conflict
    else
      redirect_to projects_path, alert: stale_alert
    end
  end

  def pm_async_action_request?
    request.headers["X-PM-Async-Action"] == "1"
  end

  def create_client_status_notification!(kind:, body:)
    Notification.create!(
      project: @pm_project,
      client: @pm_project.client,
      kind: kind,
      body: body
    )
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
    @video_types = VideoType.order(:name)
  end

  def ensure_draft_project
    return if @project.draft?

    redirect_to projects_path, alert: "Only draft projects can be edited."
  end

  def load_pm_project
    @pm_project = default_pm.projects.find(params[:id])
  end
end
