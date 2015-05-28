class Sleipnir::Entities::SmileEntity < Sleipnir::Entites::BaseEntity
  expose :user_id do |smile, options|
    smile.user.id
  end
  expose :answer_id
end
