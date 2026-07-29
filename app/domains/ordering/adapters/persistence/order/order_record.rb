module Ordering
  module Adapters
    module Persistence
      module Order
        class OrderRecord < ApplicationRecord
          self.table_name = "orders"

          belongs_to :owner, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :owner_account_id
          belongs_to :participant, class_name: "Identity::Domain::Aggregates::Account", foreign_key: :participant_account_id
          has_many :order_line_records, class_name: "Ordering::Adapters::Persistence::Order::OrderLineRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record
          has_one :source_video_record, class_name: "Ordering::Adapters::Persistence::Order::SourceVideoRecord", foreign_key: :order_id, dependent: :destroy, inverse_of: :order_record

          def video_type_selections
            order_line_records
          end

          def video_types
            order_line_records.map(&:video_type).compact
          end

          def total_budget_cents
            self[:total_budget_cents].presence || order_line_records.sum(&:line_total_cents)
          end

          def draft?
            status == "draft"
          end

          def placed?
            status == "placed"
          end

          def confirmed?
            status == "confirmed"
          end

          def completed?
            status == "completed"
          end

          def pending?
            placed?
          end

          def in_progress?
            confirmed?
          end

          def status_badge_text
            return "Borrador" if draft?
            return "Pendiente" if placed?
            return "En progreso" if confirmed?

            "Completado"
          end

          def status_badge_class
            return "text-bg-warning" if draft?
            return "text-bg-secondary" if placed?
            return "text-bg-info" if confirmed?

            "text-bg-success"
          end

          def status_badge_dom_id
            ActionView::RecordIdentifier.dom_id(self, :status_badge)
          end

          def raw_footage_metadata_hash
            raw_footage_metadata.presence || {}
          end

          def raw_footage_provider
            raw_footage_metadata_hash["provider"]
          end

          def raw_footage_embed_url(parent_host: nil)
            embed_url = raw_footage_metadata_hash["embed_url"]
            return embed_url unless raw_footage_provider == "twitch"

            embed_url&.gsub("{parent}", parent_host.presence || "localhost")
          end

          def raw_footage_social_preview?
            %w[instagram tiktok].include?(raw_footage_provider)
          end

          def raw_footage_thumbnail_url
            raw_footage_metadata_hash["thumbnail_url"]
          end

          def raw_footage_aspect_ratio
            raw_footage_metadata_hash["aspect_ratio"].presence || "16 / 9"
          end

          def raw_footage_watch_url
            raw_footage_metadata_hash["watch_url"].presence || raw_footage_url
          end

          def raw_footage_previewable?
            raw_footage_provider.present? && (raw_footage_embed_url.present? || raw_footage_social_preview?)
          end
        end
      end
    end
  end
end
