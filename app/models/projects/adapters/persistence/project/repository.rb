module Projects
  module Adapters
    module Persistence
      module Project
        class Repository < Projects::Domain::Repositories::Project::Contract
          def find_for_show(id)
            ::Project.includes(:owner, :participant, comments: :author_account, video_type_selections: :video_type).find(id)
          end

          def find_for_edit(owner, id)
            owner.projects.includes(video_type_selections: :video_type).find(id)
          end

          def find_for_workspace_action(participant, id)
            participant.projects.find(id)
          end

          def find_or_create_draft_for_owner(owner, participant)
            owner.projects.draft.order(created_at: :desc).first || owner.projects.create!(participant: participant, status: :draft)
          end

          def replace_selections(project, selections)
            project.video_type_selections.delete_all

            selections.each do |selection|
              project.video_type_selections.create!(
                video_type_id: selection.fetch(:video_type_id),
                quantity: selection.fetch(:quantity)
              )
            end
          end
        end
      end
    end
  end
end
