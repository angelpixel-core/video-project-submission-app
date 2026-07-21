require "rails_helper"

RSpec.describe RawFootageUrlParser do
  it "builds youtube metadata" do
    metadata = described_class.metadata("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

    expect(metadata).to include(
      "provider" => "youtube",
      "video_id" => "dQw4w9WgXcQ",
      "embed_url" => "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ",
      "thumbnail_url" => "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg"
    )
  end

  it "builds vimeo metadata" do
    metadata = described_class.metadata("https://player.vimeo.com/video/123456789")

    expect(metadata).to include(
      "provider" => "vimeo",
      "video_id" => "123456789",
      "embed_url" => "https://player.vimeo.com/video/123456789"
    )
    expect(metadata["thumbnail_url"]).to be_nil
  end

  it "returns nil for unrecognized urls" do
    expect(described_class.metadata("https://example.com/video")).to be_nil
  end
end
