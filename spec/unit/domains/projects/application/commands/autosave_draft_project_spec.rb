require "rails_helper"

require Rails.root.join("app/domains/projects/application/commands/autosave_draft_project")

RSpec.describe Projects::Application::Commands::AutosaveDraftProject do
  it "updates the draft project and syncs selections" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)
    highlight_reel = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    social_cut = VideoType.create!(name: "Social Cut", description: "Social edit", price_cents: 15_000, output_format: "mp4")

    result = described_class.call(
      project: project,
      participant: pm,
      attributes: { name: "Project Beta", raw_footage_url: "https://example.com/beta.mov" },
      selections: [
        { video_type_id: highlight_reel.id, quantity: 2 },
        { video_type_id: social_cut.id, quantity: 1 }
      ]
    )

    expect(result).to be_success
    expect(project.reload.status).to eq("draft")
    expect(project.name).to eq("Project Beta")
    expect(project.participant).to eq(pm)
    expect(project.video_type_selections.count).to eq(2)
  end

  it "returns a failure when the project is invalid" do
    client = workspace_account(:client, email: "client@example.com", name: "Client")
    pm = workspace_account(:pm, email: "pm@example.com", name: "PM")
    project = Project.create!(owner: client, participant: pm, status: :draft)

    allow(project).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(project))

    result = described_class.call(
      project: project,
      participant: pm,
      attributes: { name: "Project Beta", raw_footage_url: "https://example.com/beta.mov" },
      selections: []
    )

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_record)
  end
end
