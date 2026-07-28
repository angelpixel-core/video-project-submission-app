module Fulfillment
  module Application
    module Commands
      class CreateDraftProject
        def self.call(client_workspace:, pm_workspace:, repository: Fulfillment::Adapters::Persistence::Project::Repository.new)
          new(client_workspace:, pm_workspace:, repository:).call
        end

        def initialize(client_workspace:, pm_workspace:, repository:)
          @client_workspace = client_workspace
          @pm_workspace = pm_workspace
          @repository = repository
        end

        def call
          Core::Result::Success.(data: { project: draft_project })
        end

        private

        attr_reader :client_workspace, :pm_workspace, :repository

        def draft_project
          repository.find_or_create_draft_for_owner(client_workspace, pm_workspace)
        end
      end
    end
  end
end
