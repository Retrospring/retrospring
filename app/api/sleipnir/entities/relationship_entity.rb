class Sleipnir::Entities::RelationshipEntity < Sleipnir::Entities::BaseEntity
  expose :source, as: :user, with: Sleipnir::Entities::UserSlimEntity
  expose :target, as: :user, with: Sleipnir::Entities::UserSlimEntity, if: {relationship: :me}

  expose :created_at, as: :following_since, format_with: :epochtime
  expose :_created_at, as: :following_since, if: :nanotime do |object, _| object.created_at.to_i * 1000 end
end
