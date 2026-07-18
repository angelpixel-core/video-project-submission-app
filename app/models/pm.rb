class PM < ApplicationRecord
  has_many :projects, dependent: :restrict_with_error
  has_many :notifications, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def normalize_email
    self.email = EmailAddress.new(email).to_s.downcase if email.present?
  end
end
