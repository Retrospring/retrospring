class Sleipnir::Entities::InboxEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :new

  expose :question, with: Sleipnir::Entities::QuestionEntity

  expose :created_at, as: :received_at, format_with: :nanotime
end
