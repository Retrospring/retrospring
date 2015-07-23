class Sleipnir::Entities::NotificationEntity < Sleipnir::Entities::BaseEntity
  expose :id, format_with: :strid

  expose :target_type, as: :type
  expose :target do |notification, options|
    if options[:payload_id]
      notification.target_id
    elsif notification.target.nil?
      { id: notification.target_id, error: "ERR_MALFORMED_TARGET" } # test?
    else
      case notification.target_type
      when 'Comment'
        { comment: Sleipnir::Entities::CommentEntity.represent(notification.target, options) }
      when 'CommentSmile'
        { user: Sleipnir::Entities::UserSlimEntity.represent(notification.target.user, options), comment: Sleipnir::Entities::CommentEntity.represent(notification.target.comment, options) }
      when 'Smile'
        { user: Sleipnir::Entities::UserSlimEntity.represent(notification.target.user, options), answer: Sleipnir::Entities::AnswerEntity.represent(notification.target.answer, options) }
      when 'Answer'
        { answer: Sleipnir::Entities::AnswerEntity.represent(notification.target, options) }
      when 'Relationship'
        { relationship: Sleipnir::Entities::RelationshipEntity.represent(notification.target, options) }
      when 'Question'
        { question: Sleipnir::Entities::QuestionEntity.represent(notification.target, options) }
      else
        { id: notification.target_id, error: "ERR_UNKNOWN_TYPE" }
      end
    end
  end

  expose :new
end
