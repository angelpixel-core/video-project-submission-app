require "rails_helper"

RSpec.describe "Comments requests" do
  around do |example|
    original_client = ENV["DEFAULT_CLIENT_EMAIL"]
    original_pm = ENV["DEFAULT_PM_EMAIL"]

    ENV["DEFAULT_CLIENT_EMAIL"] = "client@example.com"
    ENV["DEFAULT_PM_EMAIL"] = "pm@example.com"

    example.run

    restore_env("DEFAULT_CLIENT_EMAIL", original_client)
    restore_env("DEFAULT_PM_EMAIL", original_pm)
  end

  before do
    client_account(name: "Default Client")
    pm_account(name: "Default PM")
  end

  def restore_env(key, value)
    if value.nil?
      ENV.delete(key)
    else
      ENV[key] = value
    end
  end

  it "creates a comment as the client workspace" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(owner: client, participant: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect do
      post project_comments_path(project), params: {
        comment: {
          body: "Client note",
          author_role: "client"
        }
      }
    end.to change(Comment, :count).by(1)

    comment = Comment.order(:created_at).last

    expect(response).to redirect_to(project_path(project, anchor: "project-comments"))
    expect(comment.project).to eq(project)
    expect(comment.author).to eq(client)
    expect(comment.body).to eq("Client note")

    notification = Notification.order(:created_at).last
    expect(notification.client).to be_nil
    expect(notification.pm).to eq(pm)
    expect(notification.kind).to eq("comment_created")
  end

  it "creates a comment as the pm workspace" do
    client = find_client_account
    pm = find_pm_account
    project = Project.create!(owner: client, participant: pm, name: "Project Beta", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

    expect do
      post project_comments_path(project), params: {
        comment: {
          body: "PM note",
          author_role: "pm"
        }
      }
    end.to change(Comment, :count).by(1)

    comment = Comment.order(:created_at).last

    expect(response).to redirect_to(project_path(project, anchor: "project-comments"))
    expect(comment.project).to eq(project)
    expect(comment.author).to eq(pm)
    expect(comment.body).to eq("PM note")

    notification = Notification.order(:created_at).last
    expect(notification.pm).to be_nil
    expect(notification.client).to eq(client)
    expect(notification.kind).to eq("comment_created")
  end
end
