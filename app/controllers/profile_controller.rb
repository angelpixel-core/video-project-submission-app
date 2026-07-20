require "digest"

class ProfileController < ApplicationController
  def show
    @profile_contexts = [
      {
        scope: "client",
        role_label: "Client",
        name: current_client.name,
        email: current_client.email,
        token: demo_token_for(current_client.email, "client")
      },
      {
        scope: "pm",
        role_label: "Project Manager",
        name: default_pm.name,
        email: default_pm.email,
        token: demo_token_for(default_pm.email, "pm")
      }
    ]
  end

  private

  def demo_token_for(email, role)
    "#{role}_demo_#{Digest::SHA256.hexdigest(email)[0, 20]}"
  end
end
