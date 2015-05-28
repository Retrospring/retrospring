class Sleipnir::Entities::BaseEntity < Grape::Entity
  format_with(:strid) { |id| id.to_s } # ruby has no max int, 99% of other languages do
  format_with(:nanotime) { |t| t.to_i * 1000 } # javascript
  format_with(:epochtime) { |t| t.to_i } # non-javascript

  def self.expose_image(tag, as = tag)
    expose tag, as: as do |object|
      attachment = object.send(tag)
      styles = attachment.options[:styles]
      r = {}
      for style, _ in styles
        url = attachment.url(style)
        if url[0] == "/"
          # so dirty
          url = "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}#{url}"
        end
        r[style] = url
      end
      r
    end
  end
end
