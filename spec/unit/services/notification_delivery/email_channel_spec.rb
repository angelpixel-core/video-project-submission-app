require "rails_helper"

RSpec.describe NotificationDelivery::EmailChannel do
  it "sends the PM notification email" do
    client = Client.create!(name: "Client", email: "client@example.com")
    pm = PM.create!(name: "PM", email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    mail = instance_double(ActionMailer::MessageDelivery)
    expect(PMNotificationMailer).to receive(:project_created).with(project).and_return(mail)
    expect(mail).to receive(:deliver_now)

    described_class.new(project).call
  end
end
