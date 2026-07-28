module Fulfillment
  module Application
    module Commands
      class UpdateProject
        def self.call(project:, participant:, attributes:, selections:, finalize:, repository:)
          new(project:, participant:, attributes:, selections:, finalize:, repository:).call
        end

        def initialize(project:, participant:, attributes:, selections:, finalize:, repository:)
          @project = project
          @participant = participant
          @attributes = attributes
          @selections = selections
          @finalize = finalize
          @repository = repository
        end

        def call
          if finalize
            SubmitProject.call(project: project, participant: participant, attributes: attributes, selections: selections, repository: repository)
          else
            AutosaveDraftProject.call(project: project, participant: participant, attributes: attributes, selections: selections, repository: repository)
          end
        end

        private

        attr_reader :project, :participant, :attributes, :selections, :finalize, :repository
      end
    end
  end
end
