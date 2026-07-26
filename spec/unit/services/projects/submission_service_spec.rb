require "rails_helper"

RSpec.describe Projects::SubmissionService do
  it "submits a draft project, creates a payment, and enqueues notification dispatch" do
    client = client_account
    pm = pm_account
    project = Project.create!(owner: client, participant: pm, name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)
    video_type = VideoType.create!(name: "Highlight Reel", description: "Short edit", price_cents: 25_000, output_format: "mp4")

    expect(NotificationJob).to receive(:perform_later).with(project.id)

    result = described_class.call(
      project: project,
      participant: pm,
      attributes: { name: "Project Draft", raw_footage_url: "https://example.com/draft.mov" },
      selections: [ { video_type_id: video_type.id, quantity: 2 } ]
    )

    expect(result).to be_success
    expect(project.reload.status).to eq("pending")
    expect(project.active_payment).to be_present
    expect(project.active_payment.amount_cents).to eq(50_000)
    expect(project.video_type_selections.count).to eq(1)
  end

  it "returns a failure when there are no selections" do
    project = Project.create!(owner: client_account, participant: pm_account(email: "submission-failure-pm@example.com"), name: "Project Draft", raw_footage_url: "https://example.com/draft.mov", status: :draft)

    result = described_class.call(
      project: project,
      participant: pm_account,
      attributes: { name: "Project Draft", raw_footage_url: "https://example.com/draft.mov" },
      selections: []
    )

    expect(result).to be_failure
    expect(result.message).to eq("Add at least one video type")
    expect(project.errors.full_messages).to include("Add at least one video type")
  end
end
