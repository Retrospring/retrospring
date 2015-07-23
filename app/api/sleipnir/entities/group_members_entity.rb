class Sleipnir::Entities::GroupMembersEntity < Sleipnir::Entities::BaseEntity
  expose :api_collection, as: :members, with: Sleipnir::Entities::GroupMemberEntity
end
