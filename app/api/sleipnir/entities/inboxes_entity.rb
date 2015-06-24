class Sleipnir::Entities::InboxesEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :inbox, with: Sleipnir::Entities::InboxEntity
end
