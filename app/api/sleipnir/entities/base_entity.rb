class Sleipnir::Entities::BaseEntity < Grape::Entity
  format_with(:strid) { |id| id.to_s } # ruby has no max int, 99% of other languages do
  format_with(:nanotime) { |t| t.to_i * 1000 } # javascript
  format_with(:epochtime) { |t| t.to_i } # non-javascript
end
