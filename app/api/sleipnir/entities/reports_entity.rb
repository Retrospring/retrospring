class Sleipnir::Entities::ReportsEntity < Sleipnir::Entities::CollectionEntity
  expose :api_collection, as: :reports, with: Sleipnir::Entities::ReportEntity
end
