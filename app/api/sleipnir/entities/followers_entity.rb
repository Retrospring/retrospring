class Sleipnir::Entities::FollowersEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :followers, with: Sleipnir::Entities::RelationshipEntity
end
