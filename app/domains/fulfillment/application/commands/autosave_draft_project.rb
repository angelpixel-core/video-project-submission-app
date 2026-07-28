module Fulfillment
  module Application
    module Commands
      class AutosaveDraftProject
        def self.call(project:, participant:, attributes:, selections:, repository: Fulfillment::Adapters::Persistence::Project::Repository.new)
          new(project:, participant:, attributes:, selections:, repository:).call
        end

        def initialize(project:, participant:, attributes:, selections:, repository:)
          @project = project
          @participant = participant
          @attributes = attributes
          @selections = selections
          @repository = repository
        end

        def call
          Project.transaction do
            project.with_lock do
              project.assign_attributes(attributes)
              project.participant ||= participant
              project.status = :draft
              project.save!
              repository.replace_selections(project, selections)
            end
          end

          Core::Result::Success.(data: { project: project })
        rescue ActiveRecord::RecordInvalid, ArgumentError => e
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { project_id: project.id })
        end

        private

        attr_reader :project, :participant, :attributes, :selections, :repository
      end
    end
  end
end
