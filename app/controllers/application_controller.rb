class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_client, :default_pm, :unread_notifications, :unread_client_notifications

  private

  def workspace_resolver
    @workspace_resolver ||= Workspace::Context::Provider.new
  end

  def current_client
    @current_client ||= workspace_resolver.client
  end

  def default_pm
    @default_pm ||= workspace_resolver.pm
  end

  def unread_notifications
    @unread_notifications ||= default_pm.notifications.unread.includes(project: :client_account).order(created_at: :desc)
  end

  def unread_client_notifications
    @unread_client_notifications ||= current_client.notifications.unread.includes(project: :pm_account).order(created_at: :desc)
  end
end
