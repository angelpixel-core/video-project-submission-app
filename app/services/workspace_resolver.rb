class WorkspaceResolver
  def client
    Client.find_by!(email: fetch_required_email("DEFAULT_CLIENT_EMAIL"))
  end

  def pm
    PM.find_by!(email: fetch_required_email("DEFAULT_PM_EMAIL"))
  end

  private

  def fetch_required_email(key)
    value = ENV[key].to_s.strip
    return value if value.present?

    raise KeyError, "Missing required environment variable: #{key}"
  end
end
