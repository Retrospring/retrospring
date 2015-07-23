class Sleipnir::Entities::BaseEntity < Grape::Entity
  format_with(:strid) { |id| if options[:id_to_string] then id.to_s else id end } # ruby has no max int, 99% of other languages do
  format_with(:nanotime) { |t| if options[:nanotime] then t.to_i * 1000 else t.to_i end } # javascript, no javascript
  
  def self.expose_image(tag, as = tag)
    expose tag, as: as do |object|
      attachment = object.send(tag)
      styles = attachment.options[:styles]
      r = {}
      for style, _ in styles
        r[style] = globalize_paperclip(attachment.url(style))
      end
      r
    end
  end

private

  def globalize_paperclip(entity)
    if entity[0] == "/"
      "#{options[:HOST]}#{entity}"
    else
      entity
    end
  end

  def api_collection_count
    options[:collection].length
  end

  def api_next_page
    return nil if options[:collection].last.nil?
    "#{options[:ENDPOINT]}?since_id=#{options[:collection].last.id}"
  end

  def api_collection
    options[:collection]
  end

  def application
    if object.application.nil?
      APP_FAKE_OAUTH
    else
      object.application
    end
  end
end
