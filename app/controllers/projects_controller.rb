class ProjectsController < ApplicationController
  before_action :load_project, only: %i[edit update]
  before_action :ensure_draft_project, only: %i[edit update]
  before_action :load_pm_project, only: %i[accept complete]
  before_action :load_video_types, only: %i[edit update]

  def index
    status_order = Arel.sql("CASE status WHEN 'draft' THEN 0 WHEN 'pending' THEN 1 WHEN 'in_progress' THEN 2 WHEN 'completed' THEN 3 ELSE 4 END")

    @projects = current_client.projects.includes(video_type_selections: :video_type).order(status_order, created_at: :desc)
    @pm_projects = default_pm.projects.where.not(status: :draft).includes(:client, video_type_selections: :video_type).order(status_order, created_at: :desc)
    @unread_notifications = default_pm.notifications.unread.includes(project: :client).order(created_at: :desc)
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
    end
  end

  public

  def accept
    return redirect_to(projects_path, alert: "Only pending projects can be accepted.") unless @pm_project.may_accept?

    @pm_project.accept!
    @pm_project.notifications.unread.update_all(read_at: Time.current)
    Notification.broadcast_refresh_for(@pm_project.pm)
    redirect_to projects_path, notice: "Project accepted."
  end

  def complete
    return redirect_to(projects_path, alert: "Only in-progress projects can be completed.") unless @pm_project.may_complete?

    @pm_project.complete!
    redirect_to projects_path, notice: "Project completed."
  end

  private

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
