require "rails_helper"

RSpec.describe PMNotificationMailer do
  describe "project_created" do
    it "sends a compact text email to the pm" do
      client = Client.create!(name: "Client", email: "client@example.com")
      pm = PM.create!(name: "PM", email: "pm@example.com")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_created(project)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("New project created: Project")
      expect(mail.body.encoded).to include("New project created")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Status: In progress")
    end
  end
end
