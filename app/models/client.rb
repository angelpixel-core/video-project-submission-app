class Client < ApplicationRecord
  has_one_attached :avatar

  has_many :projects, dependent: :destroy
  has_many :notifications, -> { where(pm_id: nil) }, foreign_key: :client_id, dependent: :destroy

  before_validation :normalize_email

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def normalize_email
    self.email = EmailAddress.new(email).to_s.downcase if email.present?
  end
end
