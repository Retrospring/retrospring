class Sleipnir::Entities::GroupMemberEntity < Sleipnir::Entities::BaseEntity
  expose :user, with: Sleipnir::Entities::UserSlimEntity

  expose :created_at, as: :member_since, with: :nanotime
end
