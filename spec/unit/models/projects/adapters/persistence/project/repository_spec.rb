require "rails_helper"

RSpec.describe Projects::Adapters::Persistence::Project::Repository do
  describe "#find_for_show" do
    it "loads the show associations" do
      project = Project.create!(owner: workspace_account(:client), participant: workspace_account(:pm), name: "Show me", status: :draft)

      found = described_class.new.find_for_show(project.id)

      expect(found).to eq(project)
      expect(found.association(:owner)).to be_loaded
      expect(found.association(:participant)).to be_loaded
      expect(found.association(:comments)).to be_loaded
      expect(found.association(:video_type_selections)).to be_loaded
    end
  end

  describe "#find_for_edit" do
    it "loads the edit associations" do
      client = workspace_account(:client)
      project = Project.create!(owner: client, participant: workspace_account(:pm), name: "Edit me", status: :draft)

      found = described_class.new.find_for_edit(client, project.id)

      expect(found).to eq(project)
      expect(found.association(:video_type_selections)).to be_loaded
    end
  end

  describe "#find_for_workspace_action" do
    it "scopes to the participant workspace" do
      client = workspace_account(:client)
      pm = workspace_account(:pm)
      project = Project.create!(owner: client, participant: pm, name: "Workspace action", status: :draft)

      expect(described_class.new.find_for_workspace_action(pm, project.id)).to eq(project)
    end
  end

  describe "#find_or_create_draft_for_owner" do
    it "reuses the latest draft or creates one" do
      client = workspace_account(:client)
      pm = workspace_account(:pm)
      draft = Project.create!(owner: client, participant: pm, status: :draft, name: "Draft")

      repository = described_class.new

      expect(repository.find_or_create_draft_for_owner(client, pm)).to eq(draft)
      expect { repository.find_or_create_draft_for_owner(workspace_account(:client, email: "new-client@example.com"), pm) }.to change(Project, :count).by(1)
    end
  end

  describe "#replace_selections" do
    it "replaces all project selections" do
      project = Project.create!(owner: workspace_account(:client), participant: workspace_account(:pm), name: "Selections", status: :draft)
      first_type = VideoType.create!(name: "First", description: "First edit", price_cents: 1000, output_format: "mp4")
      second_type = VideoType.create!(name: "Second", description: "Second edit", price_cents: 2000, output_format: "mp4")
      project.video_type_selections.create!(video_type: first_type, quantity: 1)

      described_class.new.replace_selections(project, [
        { video_type_id: second_type.id, quantity: 3 }
      ])

      expect(project.video_type_selections.pluck(:video_type_id, :quantity)).to contain_exactly([ second_type.id, 3 ])
    end
  end
end
