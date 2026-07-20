require "digest"
require "open-uri"

class ProfileController < ApplicationController
  def show
    @profile_contexts = [
      {
        scope: "client",
        role_label: "Client",
        record: current_client,
        name: current_client.name,
        email: current_client.email,
        token: demo_token_for(current_client.email, "client")
      },
      {
        scope: "pm",
        role_label: "Project Manager",
        record: default_pm,
        name: default_pm.name,
        email: default_pm.email,
        token: demo_token_for(default_pm.email, "pm")
      }
    ]
  end

  def update
    profile = profile_record_from_params

    if profile.nil?
      redirect_to profile_path, alert: "Unable to update profile."
      return
    end

    if remove_avatar_param?
      profile.avatar.purge if profile.avatar.attached?
    elsif (avatar = avatar_upload_param).present?
      profile.avatar.attach(avatar)
    elsif avatar_url_param.present?
      attach_avatar_from_url(profile, avatar_url_param)
    end

    redirect_to profile_path, notice: "Profile updated."
  rescue StandardError => e
    redirect_to profile_path, alert: e.message
  end

  private

  def profile_params
    params.fetch(:profile, ActionController::Parameters.new).permit(:scope, :avatar, :avatar_url, :remove_avatar)
  end

  def profile_record_from_params
    case profile_params[:scope]
    when "pm"
      default_pm
    else
      current_client
    end
  end

  def avatar_upload_param
    profile_params[:avatar]
  end

  def avatar_url_param
    profile_params[:avatar_url].to_s.strip
  end

  def remove_avatar_param?
    profile_params[:remove_avatar] == "1"
  end

  def attach_avatar_from_url(profile, url)
    uri = URI.parse(url)
    raise ArgumentError, "Avatar URL must be https://" unless uri.is_a?(URI::HTTPS)

    io = URI.open(uri, open_timeout: 5, read_timeout: 5)
    content_type = io.content_type
    raise ArgumentError, "Avatar URL must point to an image" unless content_type.to_s.start_with?("image/")

    filename = File.basename(uri.path).presence || "avatar"
    profile.avatar.attach(io: io, filename: filename, content_type: content_type)
  ensure
    io&.close
  end

  def demo_token_for(email, role)
    "#{role}_demo_#{Digest::SHA256.hexdigest(email)[0, 20]}"
  end
end
