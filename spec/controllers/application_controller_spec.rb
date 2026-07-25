require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller(ApplicationController) do
    def client_workspace
      render plain: current_client.name
    end

    def pm_workspace
      render plain: default_pm.name
    end
  end

  before do
    routes.draw do
      get "client_workspace" => "anonymous#client_workspace"
      get "pm_workspace" => "anonymous#pm_workspace"
    end
  end

  it "keeps current_client and default_pm wired to the workspace resolver" do
    client = client_account(email: "controller-client@example.com", name: "Controller Client")
    pm = pm_account(email: "controller-pm@example.com", name: "Controller PM")

    expect_any_instance_of(Identity::Application::Services::WorkspaceResolver).to receive(:client).and_return(client)
    expect_any_instance_of(Identity::Application::Services::WorkspaceResolver).to receive(:pm).and_return(pm)

    get :client_workspace
    expect(response.body).to eq("Controller Client")

    get :pm_workspace
    expect(response.body).to eq("Controller PM")
  end
end
