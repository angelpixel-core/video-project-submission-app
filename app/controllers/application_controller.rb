class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_client, :default_pm, :unread_notifications

  private

  def workspace_resolver
    @workspace_resolver ||= WorkspaceResolver.new
  end

  def current_client
    @current_client ||= workspace_resolver.client
  end

  def default_pm
    @default_pm ||= workspace_resolver.pm
  end

  def unread_notifications
    @unread_notifications ||= default_pm.notifications.unread.includes(project: :client).order(created_at: :desc)
  end
end
