require "rails_helper"

RSpec.describe "Projects requests" do
  before do
    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the client project index" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Project.create!(client: client, pm: PM.find_by!(email: "pm@example.com"), status: :draft)
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Unread PM notification")
    Notification.create!(project: project, pm: pm, kind: "project_created", body: "Read PM notification", read_at: Time.current)

    get projects_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client projects")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Borrador")
    expect(response.body).to include("Reanudar")
    expect(response.body).to include("PM workspace")
    expect(response.body).to include("PM inbox")
    expect(response.body).to include("Unread PM notification")
    expect(response.body).not_to include("Read PM notification")
  end

  it "creates a draft and redirects to edit" do
    get new_project_path

    draft = Project.order(:created_at).last

    expect(response).to redirect_to(edit_project_path(draft))
    expect(draft.status).to eq("draft")
  end

  it "redirects submitted projects away from the editor" do
    project = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    get edit_project_path(project)

    expect(response).to redirect_to(projects_path)
  end

  it "renders the draft editor" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), status: :draft)

    get edit_project_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Highlight Reel")
  end

  it "autosaves a draft and keeps it in draft status" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), status: :draft)

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
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), status: :draft)

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
  end

  it "accepts a pending project as the pm" do
    project = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), name: "Project Pending", raw_footage_url: "https://example.com/pending.mov", status: :pending)

    patch accept_project_path(project)

    expect(response).to redirect_to(projects_path)

    project.reload
    expect(project.status).to eq("in_progress")
  end

  it "completes an in-progress project as the pm" do
    project = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), name: "Project Active", raw_footage_url: "https://example.com/active.mov", status: :in_progress)

    patch complete_project_path(project)

    expect(response).to redirect_to(projects_path)

    project.reload
    expect(project.status).to eq("completed")
  end

  it "rejects finalization without selections" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: PM.find_by!(email: "pm@example.com"), status: :draft)

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
