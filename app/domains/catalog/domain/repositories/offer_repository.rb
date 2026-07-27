module Catalog
  module Domain
    module Repositories
      class OfferRepository
        def self.find_by_id(id)
          Catalog::Domain::Entities::VideoType.find_by(id: id)
        end

        def self.all
          Catalog::Domain::Entities::VideoType.order(:name)
        end

        def self.public
          all.select { |offer| Catalog::Domain::Policies::VisibilityPolicy.visible_to?(Identity::Domain::Repositories::AccountRepository.find_by_role(:client).first, offer) }
        end
      end
    end
  end
end
