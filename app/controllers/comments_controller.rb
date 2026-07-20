class CommentsController < ApplicationController
  before_action :load_project

  def create
    @comment = @project.comments.new(comment_params.except(:author_role))
    @comment.author = comment_author

    if @comment.save
      redirect_to project_path(@project, anchor: "project-comments"), notice: "Comment posted."
    else
      @comments = @project.comments.chronological.includes(:author)
      render "projects/show", status: :unprocessable_content
    end
  end

  private

  def load_project
    @project = Project.includes(:client, :pm, comments: :author, video_type_selections: :video_type).find(params[:project_id])
  end

  def comment_params
    params.require(:comment).permit(:body, :author_role)
  end

  def comment_author
    comment_params[:author_role] == "pm" ? default_pm : current_client
  end
end
