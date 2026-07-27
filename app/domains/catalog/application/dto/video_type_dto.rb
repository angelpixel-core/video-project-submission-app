module Catalog
  module Application
    module DTO
      VideoTypeDTO = Struct.new(:id, :name, :description, :price_cents, :output_format, keyword_init: true) do
        def self.from_video_type(video_type)
          new(
            id: video_type.id,
            name: video_type.name,
            description: video_type.description,
            price_cents: video_type.price_cents,
            output_format: video_type.output_format
          )
        end
      end
    end
  end
end
