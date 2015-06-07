class Sleipnir::Entities::SmilesEntity < Sleipnir::Entities::BaseEntity
  expose :users, with: Sleipnir::Entities::UserSlimEntity do |smiles, options|
    r = []
    api_collection.each do |smile|
      r.push smile.user
    end
    r
  end
end
