class Sleipnir::Entities::CommentEntity < Sleipnir::Entities::BaseEntity
  expose :id
  expose :_id, as: :id, if: :id_to_string do |object, _| object.id.to_s end

  expose :content, as: :comment

  expose :smile_count, as: :smiles

  expose :answer_id

  expose :application, as: :created_with, with: Sleipnir::Entities::ApplicationReferenceEntity

  expose :created_at, format_with: :epochtime
  expose :_created_at, as: :created_at, if: :nanotime do |object, _| object.created_at.to_i * 1000 end
end
