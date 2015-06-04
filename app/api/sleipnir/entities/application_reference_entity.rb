class Sleipnir::Entities::ApplicationReferenceEntity < Sleipnir::Entities::BaseEntity
  expose :name
  expose :description
  expose :homepage
  expose :deleted
  expose_image :icon, :icon
end
