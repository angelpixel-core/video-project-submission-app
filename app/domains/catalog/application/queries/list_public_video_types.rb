module Catalog
  module Application
    module Queries
      class ListPublicVideoTypes
        def self.call(account:)
          video_types = Catalog::Domain::Repositories::OfferRepository.all.select do |video_type|
            Catalog::Domain::Policies::VisibilityPolicy.visible_to?(account, video_type)
          end

          Core::Result::Success.(data: { video_types: video_types })
        end
      end
    end
  end
end
