class Sleipnir::Entities::QuestionsEntity < Sleipnir::Entities::BaseEntity
  expose :api_collection, as: :questions, with: Sleipnir::Entities::QuestionEntity
  expose :api_collection_count, as: :count
  expose :api_next_page, as: :next
end
