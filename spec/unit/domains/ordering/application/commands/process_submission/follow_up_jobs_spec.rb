require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "enqueues invoice and notification jobs from the success checkpoint" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project, fulfillment_account: pm)
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 789, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })

    expect(Payments::Application::Handlers::GenerateInvoiceJob).to receive(:perform_later).with(payment.id)
    expect(NotificationJob).to receive(:perform_later).with(project.id)

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |**_args| payment_result }
    )

    expect(result).to be_success
  end

  it "does not enqueue follow-up jobs when the checkpoint fails" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project, fulfillment_account: pm)
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 790, active?: false)
    payment_result = Core::Result::Success.(data: { payment: payment })

    expect(Payments::Application::Handlers::GenerateInvoiceJob).not_to receive(:perform_later)
    expect(NotificationJob).not_to receive(:perform_later)

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |**_args| payment_result }
    )

    expect(result).to be_failure
  end
end
