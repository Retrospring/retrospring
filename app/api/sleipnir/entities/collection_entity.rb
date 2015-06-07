class Sleipnir::Entities::CollectionEntity < Sleipnir::Entities::BaseEntity
  expose :api_collection_count, as: :count
  expose :api_next_page, as: :next
end
