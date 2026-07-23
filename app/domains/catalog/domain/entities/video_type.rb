module Catalog
  module Domain
    module Entities
      class VideoType < Catalog::Domain::Aggregates::Offer
        def available?
          Catalog::Domain::Policies::AvailabilityPolicy.available?(self)
        end
      end
    end
  end
end
