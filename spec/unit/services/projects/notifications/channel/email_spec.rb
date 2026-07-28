require "rails_helper"

RSpec.describe Delivery::Application::Notifications::Channel::Email do
  it "calls each delivery" do
    first = double("Delivery")
    second = double("Delivery")

    expect(first).to receive(:call)
    expect(second).to receive(:call)

    described_class.new([first, second]).call
  end
end
