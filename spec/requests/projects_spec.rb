require "rails_helper"

RSpec.describe "Projects requests" do
  include ActiveSupport::Testing::TimeHelpers

  before do
    client_account(name: "Default Client")
    pm_account(name: "Default PM")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the client project index" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Project.create!(client: client, pm: find_pm_account, status: :draft)
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Read PM notification", read_at: Time.current)

    get projects_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client projects")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Borrador")
    expect(response.body).to include("Reanudar")
    expect(response.body).to include("PM workspace")
    expect(response.body).to include("Unread notifications")
    expect(response.body).to include("Unread PM notification")
    expect(response.body).not_to include("Read PM notification")
  end

  it "shows the pm project table sorted by creation date" do
    client = find_client_account
    pm = find_pm_account
    highlight_reel = VideoType.find_by!(name: "Highlight Reel")
    social_cut = VideoType.find_by!(name: "Social Cut")

    travel_to 2.days.ago do
      older_project = Project.create!(client: client, pm: pm, name: "Older Project", raw_footage_url: "https://example.com/older.mov", status: :pending)
      older_project.video_type_selections.create!(video_type: highlight_reel, quantity: 1)
    end

    travel_to 1.day.ago do
      newer_project = Project.create!(client: client, pm: pm, name: "Newer Project", raw_footage_url: "https://example.com/newer.mov", status: :in_progress)
      newer_project.video_type_selections.create!(video_type: social_cut, quantity: 2)
    end

    get projects_path

    pm_table_body = response.body[/<tbody id="pm-projects-table-body">.*?<\/tbody>/m]

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ID")
    expect(response.body).to include("Created at")
    expect(response.body).to include("Total budget")
    expect(response.body).to include("$250.00")
    expect(response.body).to include("$300.00")
    expect(pm_table_body.index("Newer Project")).to be < pm_table_body.index("Older Project")
  ensure
    travel_back
  end

  it "shows pm table sort links" do
    client = find_client_account
    pm = find_pm_account

    Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/alpha.mov", status: :pending)

    get projects_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("ID")
    expect(response.body).to include("Created at")
    expect(response.body).to include("Total budget")
    expect(response.body).to include("pm-table-sort-link is-active")
    expect(response.body).to include("sort=id")
    expect(response.body).to include("direction=desc")
    expect(response.body).to include("sort=created_at")
    expect(response.body).to include("sort=total_budget")
  end

  it "keeps the page when generating pm table sort links" do
    client = find_client_account
    pm = find_pm_account

    11.times do |index|
      Project.create!(client: client, pm: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
    end

    get projects_path(page: 2)

    expect(response.body).to include("page=2")
    expect(response.body).to include("sort=id")
    expect(response.body).to include("sort=created_at")
    expect(response.body).to include("sort=total_budget")
    expect(response.body).to include("direction=desc")
  end

  it "shows pm pagination links and loads the second page" do
    client = find_client_account
    pm = find_pm_account

    11.times do |index|
      travel_to (10 - index).minutes.ago do
        Project.create!(client: client, pm: pm, name: "Project #{index + 1}", raw_footage_url: "https://example.com/#{index + 1}.mov", status: :pending)
      end
    end

    get projects_path(page: 2)

    pm_table_body = response.body[/<tbody id="pm-projects-table-body">.*?<\/tbody>/m]

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("PM projects pagination")
    expect(response.body).to include("Prev")
    expect(response.body).to include("1")
    expect(response.body).to include("2")
    expect(response.body).to include("Next")
    expect(pm_table_body).to include("Project 1")
    expect(pm_table_body).not_to include("Project 11")
  ensure
    travel_back
  end

  it "shows a pm project detail page" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :pending)

    get project_path(project)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Project detail")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Aceptar proyecto")
  end

  it "creates a draft and redirects to edit" do
    get new_project_path

    draft = Project.order(:created_at).last

    expect(response).to redirect_to(edit_project_path(draft))
    expect(draft.status).to eq("draft")
  end

  it "redirects submitted projects away from the editor" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    get edit_project_path(project)

    expect(response).to redirect_to(projects_path)
  end

  it "renders the draft editor" do
    draft = Project.create!(client: find_client_account, pm: find_pm_account, status: :draft)

    get edit_project_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Highlight Reel")
  end

  it "autosaves a draft and keeps it in draft status" do
    draft = Project.create!(client: find_client_account, pm: find_pm_account, status: :draft)

    patch project_path(draft), params: {
      project: {
        name: "Project Beta",
        raw_footage_url: "https://example.com/beta.mov",
        finalize: "0",
        selections_json: [
          { video_type_id: VideoType.find_by!(name: "Highlight Reel").id, quantity: 2 },
          { video_type_id: VideoType.find_by!(name: "Social Cut").id, quantity: 1 }
        ].to_json
      }
    }

    expect(response).to have_http_status(:no_content)

    draft.reload

    expect(draft.status).to eq("draft")
    expect(draft.name).to eq("Project Beta")
    expect(draft.video_type_selections.count).to eq(2)
  end

  it "finalizes a draft with selections" do
    draft = Project.create!(client: find_client_account, pm: find_pm_account, status: :draft)

    expect do
      patch project_path(draft), params: {
        project: {
          name: "Project Gamma",
          raw_footage_url: "https://example.com/gamma.mov",
          finalize: "1",
          selections_json: [
            { video_type_id: VideoType.find_by!(name: "Highlight Reel").id, quantity: 2 }
          ].to_json
        }
      }
    end.to have_enqueued_job(NotificationJob).with(draft.id)

    expect(response).to redirect_to(projects_path)

    draft.reload
    expect(draft.status).to eq("pending")
    expect(draft.pm.email).to eq("pm@example.com")
    expect(draft.video_type_selections.count).to eq(1)
    expect(draft.payments.count).to eq(1)
    expect(draft.active_payment).to be_present
    expect(draft.active_payment.amount_cents).to eq(50_000)
    expect(draft.active_payment.payment_attempts.count).to eq(1)
  end

  it "accepts a pending project as the pm" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    patch accept_project_path(project)

    expect(response).to redirect_to(projects_path)

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "accepts a pending project asynchronously" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Async", raw_footage_url: "https://example.com/async.mov", status: :pending)

    patch accept_project_path(project), headers: { "X-PM-Async-Action" => "1" }

    expect(response).to have_http_status(:no_content)

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "rejects stale asynchronous pm row actions" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Async Stale", raw_footage_url: "https://example.com/stale.mov", status: :pending)

    patch accept_project_path(project), headers: { "X-PM-Async-Action" => "1" }
    patch accept_project_path(project), headers: { "X-PM-Async-Action" => "1" }

    expect(response).to have_http_status(:conflict)
    expect(project.reload.status).to eq("in_progress")
  end

  it "completes an in-progress project as the pm" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    patch complete_project_path(project)

    expect(response).to redirect_to(projects_path)

    project.reload
    expect(project.status).to eq("completed")
  end

  it "creates a client notification when a pending project is accepted" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Client Update", raw_footage_url: "https://example.com/client-update.mov", status: :pending)

    expect do
      patch accept_project_path(project)
    end.to change(Notification, :count).by(1)

    notification = Notification.order(:created_at).last

    expect(notification.client).to eq(client)
    expect(notification.pm).to be_nil
    expect(notification.kind).to eq("project_accepted")
    expect(notification.body).to include("accepted and is now in progress")
  end

  it "creates a client notification when an in-progress project is completed" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(client: client, pm: pm, name: "Project Client Complete", raw_footage_url: "https://example.com/client-complete.mov", status: :in_progress)

    expect do
      patch complete_project_path(project)
    end.to change(Notification, :count).by(1)

    notification = Notification.order(:created_at).last

    expect(notification.client).to eq(client)
    expect(notification.pm).to be_nil
    expect(notification.kind).to eq("project_completed")
    expect(notification.body).to include("has been completed")
  end

  it "completes an in-progress project asynchronously" do
    project = Project.create!(client: find_client_account, pm: find_pm_account, name: "Project Async Complete", raw_footage_url: "https://example.com/complete.mov", status: :in_progress)

    patch complete_project_path(project), headers: { "X-PM-Async-Action" => "1" }

    expect(response).to have_http_status(:no_content)

    project.reload
    expect(project.status).to eq("completed")
  end

  it "rejects finalization without selections" do
    draft = Project.create!(client: find_client_account, pm: find_pm_account, status: :draft)

    patch project_path(draft), params: {
      project: {
        name: "Project Gamma",
        raw_footage_url: "https://example.com/gamma.mov",
        finalize: "1",
        selections_json: "[]"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Add at least one video type")
  end
end
