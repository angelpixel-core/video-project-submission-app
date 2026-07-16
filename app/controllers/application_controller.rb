class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_client, :default_pm

  private

  def current_client
    @current_client ||= Client.find_by!(email: "client@example.com")
  end

  def default_pm
    @default_pm ||= Pm.find_by!(email: "pm@example.com")
  end
end
