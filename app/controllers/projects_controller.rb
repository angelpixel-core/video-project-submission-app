class ProjectsController < ApplicationController
  before_action :load_video_types, only: %i[new create]

  def index
    @projects = current_client.projects.includes(video_type_selections: :video_type).order(created_at: :desc)
  end

  def new
    @project = current_client.projects.new
  end

  def create
    @project = current_client.projects.new(project_attributes)
    @project.pm = default_pm
    @project.status = :in_progress

    selections = parsed_selections

    if selections.empty?
      @project.errors.add(:base, "Add at least one video type")
      load_video_types
      render :new, status: :unprocessable_content
      return
    end

    Project.transaction do
      @project.save!
      selections.each do |selection|
        @project.video_type_selections.create!(
          video_type_id: selection.fetch(:video_type_id),
          quantity: selection.fetch(:quantity)
        )
      end
    end

    redirect_to projects_path, notice: "Project created."
  rescue ActiveRecord::RecordInvalid, ArgumentError, JSON::ParserError, ActionController::ParameterMissing => e
    @project.errors.add(:base, e.message)
    load_video_types
    render :new, status: :unprocessable_content
  end

  private

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

  def load_video_types
    @video_types = VideoType.order(:name)
  end
end
