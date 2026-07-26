module Projects
  module Application
    module Commands
      class CreateDraftProject
        def self.call(client_workspace:, pm_workspace:)
          new(client_workspace:, pm_workspace:).call
        end

        def initialize(client_workspace:, pm_workspace:)
          @client_workspace = client_workspace
          @pm_workspace = pm_workspace
        end

        def call
          Core::Result::Success.(data: { project: draft_project })
        end

        private

        attr_reader :client_workspace, :pm_workspace

        def draft_project
          client_workspace.projects.draft.order(created_at: :desc).first ||
            client_workspace.projects.create!(participant: pm_workspace, status: :draft)
        end
      end
    end
  end
end
