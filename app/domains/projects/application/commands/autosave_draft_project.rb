module Projects
  module Application
    module Commands
      class AutosaveDraftProject
        def self.call(project:, participant:, attributes:, selections:)
          new(project:, participant:, attributes:, selections:).call
        end

        def initialize(project:, participant:, attributes:, selections:)
          @project = project
          @participant = participant
          @attributes = attributes
          @selections = selections
        end

        def call
          Project.transaction do
            project.with_lock do
              project.assign_attributes(attributes)
              project.participant ||= participant
              project.status = :draft
              project.save!
              sync_project_selections
            end
          end

          Core::Result::Success.(data: { project: project })
        rescue ActiveRecord::RecordInvalid, ArgumentError => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { project_id: project.id })
        end

        private

        attr_reader :project, :participant, :attributes, :selections

        def sync_project_selections
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
