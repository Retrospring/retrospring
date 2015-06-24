class Sleipnir::Entities::InboxEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :new

  expose :question, with: Sleipnir::Entities::QuestionEntity

  expose :created_at, as: :received_at, format_with: :epochtime
  expose :_created_at, as: :received_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 end
end
