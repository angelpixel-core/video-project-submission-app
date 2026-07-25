module Identity
  module Adapters
    module Persistence
      module Account
        class AccountRecord < ApplicationRecord
          self.table_name = "accounts"

          has_one_attached :avatar

          has_many :client_projects, class_name: "Project", foreign_key: :client_account_id, dependent: :restrict_with_error
          has_many :pm_projects, class_name: "Project", foreign_key: :pm_account_id, dependent: :restrict_with_error
          has_many :notifications, class_name: "Notification", foreign_key: :account_id, dependent: :destroy
          has_many :comments, class_name: "Comment", foreign_key: :author_account_id, dependent: :destroy
          has_many :memberships, class_name: "Identity::Domain::Aggregates::Membership", foreign_key: :account_id, dependent: :destroy
          has_many :users, through: :memberships

          before_validation :normalize_email
          before_validation :normalize_role

          validates :name, presence: true
          validates :email, presence: true, uniqueness: { scope: :role, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
          validates :role, presence: true, inclusion: { in: Identity::Domain::ValueObjects::Role::ALLOWED_VALUES }

          def role_object
            Identity::Domain::ValueObjects::Role.new(role)
          end

          def client?
            role_object.client?
          end

          def pm?
            role_object.pm?
          end

          def projects
            client? ? client_projects : pm_projects
          end

          def membership_for(user)
            memberships.find_by(user_id: user.id)
          end

          def role_for(user)
            membership_for(user)&.role_object
          end

          def users_with_role(role)
            memberships.where(role: role.to_s.strip.downcase).includes(:user).map(&:user)
          end

          def normalize_for_role!
            normalize_role
            self
          end

          private

          def normalize_email
            self.email = Identity::Domain::ValueObjects::Email.new(email).to_s if email.present?
          rescue ArgumentError
            # Let the model validation surface the issue.
          end

          def normalize_role
            self.role = role.to_s.strip.downcase
          end
        end
      end
    end
  end
end
