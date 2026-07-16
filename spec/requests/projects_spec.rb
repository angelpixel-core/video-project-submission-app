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
    project = Project.create!(client: client, pm: Pm.find_by!(email: "pm@example.com"), name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov")

    get projects_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Default Client projects")
    expect(response.body).to include("Project Alpha")
  end

  it "renders the order form" do
    get new_project_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Create a new project")
    expect(response.body).to include("Highlight Reel")
  end

  it "creates a project with selections" do
    post projects_path, params: {
      project: {
        name: "Project Beta",
        raw_footage_url: "https://example.com/beta.mov",
        selections_json: [
          { video_type_id: VideoType.find_by!(name: "Highlight Reel").id, quantity: 2 },
          { video_type_id: VideoType.find_by!(name: "Social Cut").id, quantity: 1 }
        ].to_json
      }
    }

    expect(response).to redirect_to(projects_path)

    project = Project.find_by!(name: "Project Beta")
    expect(project.status).to eq("in_progress")
    expect(project.pm.email).to eq("pm@example.com")
    expect(project.video_type_selections.count).to eq(2)
  end

  it "rejects a submission without selections" do
    post projects_path, params: {
      project: {
        name: "Project Gamma",
        raw_footage_url: "https://example.com/gamma.mov",
        selections_json: "[]"
      }
    }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("Add at least one video type")
  end
end
