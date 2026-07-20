require "rails_helper"

RSpec.describe "Comments requests" do
  before do
    Client.create!(name: "Default Client", email: "client@example.com")
    PM.create!(name: "Default PM", email: "pm@example.com")
  end

  it "creates a comment as the client workspace" do
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Alpha", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

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
    client = Client.find_by!(email: "client@example.com")
    pm = PM.find_by!(email: "pm@example.com")
    project = Project.create!(client: client, pm: pm, name: "Project Beta", raw_footage_url: "https://example.com/raw.mov", status: :in_progress)

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
