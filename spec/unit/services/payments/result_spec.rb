require "rails_helper"

RSpec.describe Payments::Result::Success do
  it "exposes a success contract" do
    result = described_class.(data: { payment_id: 1 })

    expect(result).to be_success
    expect(result).not_to be_failure
    expect(result.data).to eq({ payment_id: 1 })
    expect(result.message).to be_nil
    expect(result.code).to be_nil
  end
end

RSpec.describe Payments::Result::Failure do
  it "exposes a failure contract" do
    result = described_class.(message: "Rejected", code: :provider_rejected, data: { provider_reference: "fake-1" })

    expect(result).to be_failure
    expect(result).not_to be_success
    expect(result.data).to eq({ provider_reference: "fake-1" })
    expect(result.message).to eq("Rejected")
    expect(result.code).to eq(:provider_rejected)
  end
end
