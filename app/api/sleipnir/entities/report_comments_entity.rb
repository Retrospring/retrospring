class Sleipnir::Entities::ReportCommentsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :comments, with: Sleipnir::Entities::ReportCommentEntity
end
