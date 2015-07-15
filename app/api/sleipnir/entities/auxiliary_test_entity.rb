class Sleipnir::Entities::AuxiliaryTestEntity < Sleipnir::Entities::BaseEntity
  expose :number, format_with: :strid
  expose :time, format_with: :nanotime
  expose :string
  expose :float
  expose :map
  expose :dictionary
  expose :void
end
