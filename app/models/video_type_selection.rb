class VideoTypeSelection < ApplicationRecord
  belongs_to :project
  belongs_to :video_type

  after_create :sync_order_listing
  after_destroy :sync_order_listing

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :video_type_id, uniqueness: { scope: :project_id }

  private

  def sync_order_listing
    project.sync_order_listing! if project.present?
  end
end
