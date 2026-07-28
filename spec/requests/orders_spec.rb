require "rails_helper"

RSpec.describe "Orders requests" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    workspace_account(:client, name: "Default Client")
    workspace_account(:pm, name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the order shell index" do
    client = find_workspace_account(:client, email: "client@example.com")
    pm = find_workspace_account(:pm, email: "pm@example.com")
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Read PM notification", read_at: Time.current)

    get orders_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client orders")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("/orders")
    expect(response.body).to include("PM workspace")
    expect(response.body).to include("Unread notifications")
    expect(response.body).to include("Order update")
    expect(response.body).to include("Unread PM notification")
    expect(response.body).not_to include("Read PM notification")
  end

  it "creates a draft and redirects to edit" do
    get new_order_path

    draft = Project.order(:created_at).last

    expect(response).to redirect_to(edit_order_path(draft))
    expect(draft.status).to eq("draft")
  end

  it "redirects submitted projects away from the editor" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    get edit_order_path(project)

    expect(response).to redirect_to(orders_path)
  end

  it "renders the draft editor" do
    draft = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), status: :draft)

    get edit_order_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Back to orders")
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Review and pay")
    expect(response.body).not_to include("Project detail")
    expect(response.body).to include("Highlight Reel")
  end

  it "renders the order detail page" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Detail", raw_footage_url: "https://example.com/detail.mov", status: :pending)

    get order_path(project)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Order detail")
    expect(response.body).to include("Back to orders")
    expect(response.body).to include("Aceptar orden")
  end

  it "accepts a pending project as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    patch accept_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "completes an in-progress project as the pm" do
    project = Project.create!(owner: find_workspace_account(:client, email: "client@example.com"), participant: find_workspace_account(:pm, email: "pm@example.com"), name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    patch complete_order_path(project)

    expect(response).to redirect_to(orders_path)

    project.reload
    expect(project.status).to eq("completed")
  end
end
