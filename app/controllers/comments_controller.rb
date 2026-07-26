class CommentsController < ApplicationController
  before_action :load_project

  def create
    @comment = @project.comments.new(comment_params.except(:author_role))
    @comment.author = comment_author

    if @comment.save
      create_comment_notification!(@comment)
      redirect_to project_path(@project, anchor: "project-comments"), notice: "Comment posted."
    else
      @comments = @project.comments.chronological.includes(:author_account)
      render "projects/show", status: :unprocessable_content
    end
  end

  private

  def load_project
    @project = Project.includes(:client_account, :pm_account, comments: :author_account, video_type_selections: :video_type).find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :author_role)
  end

  def comment_author
    comment_params[:author_role] == "pm" ? workspace_for(:pm) : workspace_for(:client)
  end

  def create_comment_notification!(comment)
    if comment.author.pm?
      Notification.create!(project: @project, client: @project.client, kind: "comment_created", body: "New comment from PM on #{@project.name.presence || 'Untitled project'}.")
    else
      Notification.create!(project: @project, pm: @project.pm, kind: "comment_created", body: "New comment from client on #{@project.name.presence || 'Untitled project'}.")
    end
  end
end
