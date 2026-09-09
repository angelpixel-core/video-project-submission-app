require "rails_helper"

RSpec.describe LocaleMiddleware do
  let(:captured) { {} }
  let(:app) do
    lambda do |env|
      captured[:locale] = I18n.locale
      captured[:env_locale] = env[described_class::LOCALE_ENV_KEY]
      [ 200, { "Content-Type" => "text/plain" }, [ "ok" ] ]
    end
  end

  subject(:middleware) { described_class.new(app) }

  it "uses the supported locale from the path" do
    middleware.call(Rack::MockRequest.env_for("/es/orders"))

    expect(captured[:locale]).to eq(:es)
    expect(captured[:env_locale]).to eq("es")
    expect(I18n.locale).to eq(I18n.default_locale)
  end

  it "falls back to english for unsupported locales and logs a warning" do
    allow(Rails.logger).to receive(:warn)

    middleware.call(Rack::MockRequest.env_for("/fr/orders"))

    expect(captured[:locale]).to eq(:en)
    expect(captured[:env_locale]).to eq("en")
    expect(Rails.logger).to have_received(:warn).with(/Unsupported locale 'fr'.*falling back to en/)
  end

  it "defaults to english when no locale prefix is present" do
    middleware.call(Rack::MockRequest.env_for("/orders"))

    expect(captured[:locale]).to eq(:en)
    expect(captured[:env_locale]).to eq("en")
  end
end
