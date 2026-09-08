require "rails_helper"

RSpec.describe Ordering::Application::Commands::ProcessSubmission do
  it "returns the documented success data contract" do
    submission = double("Submission", order: order, fulfillment_account: double("Account"), line_items: [ line_item ], payment_provider: "fake", payment_method_type: "card")
    payment = double("Payment", id: 123, active?: true)
    reservation = double("CapacityReservation", order_id: 1)
    success = Core::Result::Success.(data: { payment: payment })
    reservation_success = Core::Result::Success.(data: { reservation: reservation })
    availability = double("AvailabilityPolicy", evaluate: double("Availability", unavailable?: false))

    result = described_class.call(
      submission: submission,
      payment_command: ->(**) { success },
      availability_policy: availability,
      capacity_reserve_command: ->(**) { reservation_success },
      capacity_commit_command: ->(**) { reservation_success },
      capacity_release_command: ->(**) { raise "release should not be called" },
      invoice_follow_up: ->(_payment) { },
      notification_follow_up: ->(_order) { }
    )

    expect(result).to be_success
    expect(result.data).to eq(
      submission: submission,
      order: order,
      payment: payment,
      reservation: reservation
    )
  end

  it "returns the documented validation failure context" do
    submission = double("Submission", order: order, fulfillment_account: double("Account"), line_items: [], payment_provider: "fake", payment_method_type: "card")

    result = described_class.call(
      submission: submission,
      payment_command: ->(**) { raise "payment should not be called" },
      invoice_follow_up: ->(_payment) { raise "follow-up should not be called" },
      notification_follow_up: ->(_order) { raise "follow-up should not be called" }
    )

    expect(result).to be_failure
    expect(result.code).to eq(:invalid_record)
    expect(result.data).to include(submission: submission, order: order)
  end

  private

  def order
    @order ||= double("Order", id: 1, submitted?: true)
  end

  def line_item
    @line_item ||= double("LineItem", quantity: 1, offer_variant: double("OfferVariant"))
  end
end
