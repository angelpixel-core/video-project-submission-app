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
    reservation = instance_double("CapacityReservation", order_id: project.id)
    reserve_result = Core::Result::Success.(data: { reservation: reservation })
    commit_result = Core::Result::Success.(data: { reservation: reservation })
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")
    invoicing_port = instance_double("InvoicingPort")
    notification_port = instance_double("NotificationPort")

    expect(reserve_command).to receive(:call).with(order_id: project.id, units: 1).and_return(reserve_result)
    expect(payment_command).to receive(:call).and_return(payment_result)
    expect(commit_command).to receive(:call).with(order_id: project.id).and_return(commit_result)
    expect(release_command).not_to receive(:call)
    expect(invoicing_port).to receive(:call).with(payment: payment)
    expect(notification_port).to receive(:call).with(order: project)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command,
      invoicing_port: invoicing_port,
      notification_port: notification_port
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
    reservation = instance_double("CapacityReservation", order_id: project.id)
    reserve_result = Core::Result::Success.(data: { reservation: reservation })
    reserve_command = instance_double("ReserveCapacity")
    commit_command = instance_double("CommitCapacity")
    release_command = instance_double("ReleaseCapacity")
    payment_command = instance_double("PaymentCommand")
    invoicing_port = instance_double("InvoicingPort")
    notification_port = instance_double("NotificationPort")

    expect(reserve_command).to receive(:call).with(order_id: project.id, units: 1).and_return(reserve_result)
    expect(payment_command).to receive(:call).and_return(payment_result)
    expect(commit_command).not_to receive(:call)
    expect(release_command).to receive(:call).with(order_id: project.id)
    expect(invoicing_port).not_to receive(:call)
    expect(notification_port).not_to receive(:call)

    result = described_class.call(
      submission: submission,
      payment_command: payment_command,
      capacity_reserve_command: reserve_command,
      capacity_commit_command: commit_command,
      capacity_release_command: release_command,
      invoicing_port: invoicing_port,
      notification_port: notification_port
    )

    expect(result).to be_failure
  end
end
