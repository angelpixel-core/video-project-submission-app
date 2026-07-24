require "rails_helper"

RSpec.describe PMNotificationMailer do
  describe "project_created" do
    it "sends a compact text email to the pm" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_created(project)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("New project created: Project")
      expect(mail.body.encoded).to include("New project created")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Client: Client")
      expect(mail.body.encoded).to include("Status: In progress")
      expect(mail.body.encoded).to include("Budget:")
    end
  end

  describe "project_accepted" do
    it "sends a compact text email to the pm" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Project accepted: Project")
      expect(mail.body.encoded).to include("Project accepted")
      expect(mail.body.encoded).to include("The client has been notified")
    end
  end

  describe "project_rejected" do
    it "sends a compact text email to the pm" do
      client = client_account(name: "Client")
      pm = pm_account(name: "PM")
      project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Project rejected: Project")
      expect(mail.body.encoded).to include("Project rejected")
      expect(mail.body.encoded).to include("The client should be notified")
    end
  end
end
