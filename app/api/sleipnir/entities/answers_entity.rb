class Sleipnir::Entities::AnswersEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :answers, with: Sleipnir::Entities::AnswerEntity
end
