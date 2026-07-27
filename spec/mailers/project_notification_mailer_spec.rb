require "rails_helper"

RSpec.describe ProjectNotificationMailer do
  describe "project_created" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_created(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project was created")
      expect(mail.body.encoded).to include("Your project was created")
      expect(mail.body.encoded).to include("Project: Project")
      expect(mail.body.encoded).to include("Status: Pending")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_created(project, recipient_role: :pm)

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
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project was accepted")
      expect(mail.body.encoded).to include("Your project was accepted")
      expect(mail.body.encoded).to include("Next step: Your PM has accepted the project")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

      mail = described_class.project_accepted(project, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Project accepted: Project")
      expect(mail.body.encoded).to include("Project accepted")
      expect(mail.body.encoded).to include("The client has been notified")
    end
  end

  describe "project_rejected" do
    it "sends a compact text email to the client" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project, recipient_role: :client)

      expect(mail.to).to eq([ "client@example.com" ])
      expect(mail.subject).to eq("Your project Project needs attention")
      expect(mail.body.encoded).to include("Your project needs attention")
      expect(mail.body.encoded).to include("Next step: Your PM needs changes")
    end

    it "sends a compact text email to the pm" do
      client = workspace_account(:client, name: "Client")
      pm = workspace_account(:pm, name: "PM")
      project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)

      mail = described_class.project_rejected(project, recipient_role: :pm)

      expect(mail.to).to eq([ "pm@example.com" ])
      expect(mail.subject).to eq("Project rejected: Project")
      expect(mail.body.encoded).to include("Project rejected")
      expect(mail.body.encoded).to include("The client should be notified")
    end
  end
end
