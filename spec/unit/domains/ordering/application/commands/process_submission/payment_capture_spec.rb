require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "processes a submission and creates payment via the payment command" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = Ordering::Application::DTO::Submission.from_project(project_bridge, fulfillment_account: pm)
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 123, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })

    payment_command = lambda do |project:, provider:, payment_method_type:|
      expect(project).to eq(project_bridge)
      expect(provider).to eq("fake")
      expect(payment_method_type).to eq("card")
      payment_result
    end

    result = described_class.call(submission: submission, payment_command: payment_command)

    expect(result).to be_success
    expect(result.data.fetch(:submission)).to eq(submission)
    expect(result.data.fetch(:order)).to eq(project_bridge)
    expect(result.data.fetch(:payment)).to eq(payment)
  end

  it "returns the payment failure when the payment command fails" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = Ordering::Application::DTO::Submission.from_project(project_bridge, fulfillment_account: pm)
    payment_result = Core::Result::Failure.(message: "gateway down", code: :provider_error, data: { provider: "fake" })

    expect(Payments::Application::Handlers::GenerateInvoiceJob).not_to receive(:perform_later)
    expect(NotificationJob).not_to receive(:perform_later)

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |_args| payment_result }
    )

    expect(result).to be_failure
    expect(result.message).to eq("gateway down")
    expect(result.code).to eq(:provider_error)
  end
end
