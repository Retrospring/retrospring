class Sleipnir::Entities::CommentsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :comments, with: Sleipnir::Entities::CommentEntity
end
