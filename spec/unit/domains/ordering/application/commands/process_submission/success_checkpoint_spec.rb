require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "fails when the payment has not reached the checkpoint state" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_project(project, fulfillment_account: pm)
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 456, active?: false)
    payment_result = Core::Result::Success.(data: { payment: payment })

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |_args| payment_result }
    )

    expect(result).to be_failure
    expect(result.message).to eq("Payment must be active before success checkpoint")
  end
end
