require "rails_helper"

RSpec.describe ClientNotificationMailer do
  describe "project_created" do
    it "sends a compact text email to the client" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_created(project)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project was created")
      expect(mail.body.encoded).to include("Your project was created")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Status: Pending")
    end
  end

  describe "project_accepted" do
    it "sends a compact text email to the client" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project was accepted")
      expect(mail.body.encoded).to include("Your project was accepted")
      expect(mail.body.encoded).to include("Next step: Your PM has accepted the project")
    end
  end

  describe "project_rejected" do
    it "sends a compact text email to the client" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project needs attention")
      expect(mail.body.encoded).to include("Your project needs attention")
      expect(mail.body.encoded).to include("Next step: Your PM needs changes")
    end
  end
end
