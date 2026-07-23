class PM < Identity::Domain::Aggregates::Account
  self.inheritance_column = :_type_disabled

  default_scope { where(role: "pm") }

  before_validation do
    self.role = "pm"
  end
end
