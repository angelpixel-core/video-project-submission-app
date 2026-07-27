module Projects
  module Application
    module Commands
      class SubmitProject
        def self.call(project:, participant:, attributes:, selections:, repository: Projects::Adapters::Persistence::Project::Repository.new)
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
          return missing_selections_failure if selections.empty?

          payment_result = nil
          payment = nil
          payment_failed = false

          Project.transaction do
            project.with_lock do
              project.assign_attributes(attributes)
              project.participant = participant
              project.submit!
              repository.replace_selections(project, selections)

              payment_result = Payments::Application::Commands::CreatePayment.(project: project)
              if payment_result.failure?
                project.errors.add(:base, payment_result.message)
                payment_failed = true
                raise ActiveRecord::Rollback
              end

              payment = payment_result.data.fetch(:payment)
            end
          end

          return payment_failure(payment_result) if payment_failed

          NotificationJob.perform_later(project.id)

          Core::Result::Success.(data: { project: project, payment: payment })
        rescue AASM::InvalidTransition, ActiveRecord::RecordInvalid => e
          project.errors.add(:base, e.message) if project.errors.empty?
          Core::Result::Failure.(message: e.message, code: :invalid_record, data: { project_id: project.id })
        end

        private

        attr_reader :project, :participant, :attributes, :selections, :repository

        def missing_selections_failure
          project.errors.add(:base, "Add at least one video type")
          Core::Result::Failure.(message: "Add at least one video type", code: :invalid_record, data: { project_id: project.id })
        end

        def payment_failure(payment_result)
          Core::Result::Failure.(message: payment_result.message, code: payment_result.code, data: payment_result.data.merge(project_id: project.id))
        end
      end
    end
  end
end
