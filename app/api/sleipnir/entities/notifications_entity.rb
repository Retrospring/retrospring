class Sleipnir::Entities::NotificationsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :notifications, with: Sleipnir::Entities::NotificationEntity
end
