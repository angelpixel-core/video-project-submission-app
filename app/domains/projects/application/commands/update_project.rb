module Projects
  module Application
    module Commands
      class UpdateProject
        def self.call(project:, participant:, attributes:, selections:, finalize:)
          new(project:, participant:, attributes:, selections:, finalize:).call
        end

        def initialize(project:, participant:, attributes:, selections:, finalize:)
          @project = project
          @participant = participant
          @attributes = attributes
          @selections = selections
          @finalize = finalize
        end

        def call
          if finalize
            SubmitProject.call(project: project, participant: participant, attributes: attributes, selections: selections)
          else
            AutosaveDraftProject.call(project: project, participant: participant, attributes: attributes, selections: selections)
          end
        end

        private

        attr_reader :project, :participant, :attributes, :selections, :finalize
      end
    end
  end
end
