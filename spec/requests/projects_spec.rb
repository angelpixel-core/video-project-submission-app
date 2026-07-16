require "rails_helper"

RSpec.describe "Projects requests" do
  before do
    Client.create!(name: "Default Client", email: "client@example.com")
    Pm.create!(name: "Default PM", email: "pm@example.com")
    VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")
  end

  it "shows the client project index" do
    client = Client.find_by!(email: "client@example.com")
    project = Project.create!(client: client, pm: Pm.find_by!(email: "pm@example.com"), name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)
    Project.create!(client: client, pm: Pm.find_by!(email: "pm@example.com"), status: :draft)

    get projects_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client projects")
    expect(response.body).to include("Project Alpha")
    expect(response.body).to include("Borrador")
    expect(response.body).to include("Reanudar")
  end

  it "creates a draft and redirects to edit" do
    get new_project_path

    draft = Project.order(:created_at).last

    expect(response).to redirect_to(edit_project_path(draft))
    expect(draft.status).to eq("draft")
  end

  it "renders the draft editor" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: Pm.find_by!(email: "pm@example.com"), status: :draft)

    get edit_project_path(draft)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Resume draft")
    expect(response.body).to include("Highlight Reel")
  end

  it "autosaves a draft and keeps it in draft status" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: Pm.find_by!(email: "pm@example.com"), status: :draft)

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
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: Pm.find_by!(email: "pm@example.com"), status: :draft)

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
    expect(draft.status).to eq("in_progress")
    expect(draft.pm.email).to eq("pm@example.com")
    expect(draft.video_type_selections.count).to eq(1)
  end

  it "rejects finalization without selections" do
    draft = Project.create!(client: Client.find_by!(email: "client@example.com"), pm: Pm.find_by!(email: "pm@example.com"), status: :draft)

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
