PaymentStatusChanged = Struct.new(:payment_id, :project_id, :from_status, :to_status, :event_type, :payload, keyword_init: true) do
  def to_h
    {
      payment_id: payment_id,
      project_id: project_id,
      from_status: from_status,
      to_status: to_status,
      event_type: event_type,
      payload: payload
    }
  end
end
