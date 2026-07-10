class EmailAddress
  attr_reader :value

  def initialize(value)
    @value = value.to_s.strip
  end

  def to_s
    value
  end
end
