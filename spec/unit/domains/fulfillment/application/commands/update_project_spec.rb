require "rails_helper"

require Rails.root.join("app/domains/fulfillment/application/commands/update_project")

RSpec.describe Fulfillment::Application::Commands::UpdateProject do
  it "delegates to autosave when finalize is false" do
    project = instance_double(Project)
    participant = instance_double(Identity::Domain::Aggregates::Account)
    attributes = { name: "Draft" }
    selections = []
    result = Core::Result::Success.(data: { project: project })

    expect(Fulfillment::Application::Commands::AutosaveDraftProject).to receive(:call).with(project: project, participant: participant, attributes: attributes, selections: selections).and_return(result)

    expect(
      described_class.call(project: project, participant: participant, attributes: attributes, selections: selections, finalize: false)
    ).to eq(result)
  end

  it "delegates to submit when finalize is true" do
    project = instance_double(Project)
    participant = instance_double(Identity::Domain::Aggregates::Account)
    attributes = { name: "Final" }
    selections = []
    result = Core::Result::Failure.(message: "nope", code: :invalid_record)

    expect(Fulfillment::Application::Commands::SubmitProject).to receive(:call).with(project: project, participant: participant, attributes: attributes, selections: selections).and_return(result)

    expect(
      described_class.call(project: project, participant: participant, attributes: attributes, selections: selections, finalize: true)
    ).to eq(result)
  end
end
