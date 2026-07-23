class Client < Identity::Domain::Aggregates::Account
  self.inheritance_column = :_type_disabled

  default_scope { where(role: "client") }

  before_validation do
    self.role = "client"
  end
end
