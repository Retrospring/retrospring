class Sleipnir::Entities::FollowingsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :followings, with: Sleipnir::Entities::RelationshipEntity
end
