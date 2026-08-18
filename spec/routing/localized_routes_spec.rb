require "rails_helper"

RSpec.describe "Localized routes", type: :routing do
  it "routes the localized orders index" do
    expect(get: "/es/orders").to route_to(controller: "orders", action: "index", locale: "es")
  end

  it "routes the localized root path" do
    expect(get: "/es").to route_to(controller: "orders", action: "index", locale: "es")
  end

  it "routes the default root path without a locale" do
    expect(get: "/").to route_to(controller: "orders", action: "index")
  end
end
