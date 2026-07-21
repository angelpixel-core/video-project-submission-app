require "uri"

class RawFootageUrlParser
  VIMEO_HOSTS = %w[vimeo.com www.vimeo.com player.vimeo.com].freeze

  def self.metadata(url)
    youtube_metadata(url) || vimeo_metadata(url)
  end

  def self.youtube_metadata(url)
    video_id = YoutubeUrlParser.video_id(url)
    return unless video_id

    {
      "provider" => "youtube",
      "video_id" => video_id,
      "embed_url" => "https://www.youtube-nocookie.com/embed/#{video_id}",
      "thumbnail_url" => "https://img.youtube.com/vi/#{video_id}/hqdefault.jpg",
      "watch_url" => "https://www.youtube.com/watch?v=#{video_id}"
    }
  end

  def self.vimeo_metadata(url)
    video_id = vimeo_video_id(url)
    return unless video_id

    {
      "provider" => "vimeo",
      "video_id" => video_id,
      "embed_url" => "https://player.vimeo.com/video/#{video_id}",
      "watch_url" => "https://vimeo.com/#{video_id}"
    }
  end

  def self.vimeo_video_id(url)
    uri = parse(url)
    return unless uri&.host.present? && VIMEO_HOSTS.include?(uri.host.downcase)

    segments = path_segments(uri.path)

    if uri.host.downcase == "player.vimeo.com"
      return segments.second if segments.first == "video"
    end

    segments.reverse.find { |segment| segment.match?(/\A\d+\z/) }
  end
  private_class_method :vimeo_video_id

  def self.parse(url)
    normalized_url = normalize(url)
    URI.parse(normalized_url) if normalized_url.present?
  rescue URI::InvalidURIError
    nil
  end
  private_class_method :parse

  def self.normalize(url)
    value = url.to_s.strip
    return if value.blank?

    return value if value.match?(/\A[a-z][a-z0-9+.-]*:\/\//i)

    "https://#{value}"
  end
  private_class_method :normalize

  def self.path_segments(path)
    path.to_s.split("/").reject(&:blank?)
  end
  private_class_method :path_segments
end
