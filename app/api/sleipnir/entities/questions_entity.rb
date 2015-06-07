class Sleipnir::Entities::QuestionsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :questions, with: Sleipnir::Entities::QuestionEntity
end
