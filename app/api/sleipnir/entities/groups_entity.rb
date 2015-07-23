class Sleipnir::Entities::GroupsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :groups, with: Sleipnir::Entities::GroupEntity
end
