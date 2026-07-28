class ProjectsController < ApplicationController
  include WorkspaceProjectShell

  prepend_view_path Rails.root.join("app/views/projects")
end
