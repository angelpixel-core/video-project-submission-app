require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "processes a submission and creates payment via the payment command" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 2)

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm)
    payment_gateway = instance_double("PaymentGateway")
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 123, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })

    payment_command = lambda do |order:, provider:, payment_method_type:, gateway:|
      expect(order).to eq(project_bridge)
      expect(provider).to eq("fake")
      expect(payment_method_type).to eq("card")
      expect(gateway).to eq(payment_gateway)
      payment_result
    end

    result = described_class.call(submission: submission, payment_command: payment_command, payment_gateway: payment_gateway)

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

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm)
    payment_result = Core::Result::Failure.(message: "gateway down", code: :provider_error, data: { provider: "fake" })

    expect(Payments::Application::Handlers::GenerateInvoiceJob).not_to receive(:perform_later)
    expect(NotificationJob).not_to receive(:perform_later)

    result = described_class.call(
      submission: submission,
      payment_command: lambda { |**_args| payment_result }
    )

    expect(result).to be_failure
    expect(result.message).to eq("gateway down")
    expect(result.code).to eq(:provider_error)
  end

  it "resolves an alternate provider through the gateway container" do
    client = workspace_account(:client, name: "Client")
    pm = workspace_account(:pm, name: "PM")
    project_bridge = Project.create!(owner: client, participant: pm, name: "Project", raw_footage_url: "https://example.com/raw.mov", status: :pending)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")
    project_bridge.video_type_selections.create!(video_type: video_type, quantity: 1)

    submission = Ordering::Application::DTO::Submission.from_order(project_bridge, fulfillment_account: pm, payment_provider: "stripe")
    payment = instance_double(Payments::Domain::Aggregates::Payment, id: 999, active?: true)
    payment_result = Core::Result::Success.(data: { payment: payment })
    payment_gateway = Payments::Application::Gateways.resolve("stripe")

    result = described_class.call(
      submission: submission,
      payment_gateway: payment_gateway,
      payment_command: lambda { |order:, provider:, payment_method_type:, gateway:|
        expect(provider).to eq("stripe")
        expect(gateway).to eq(payment_gateway)
        payment_result
      }
    )

    expect(result).to be_success
  end
end
