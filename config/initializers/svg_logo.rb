# frozen_string_literal: true

return unless APP_CONFIG[:use_svg_logo]

begin
  logo_path = Rails.public_path.join("logo.svg")
  # we are only interested in the first element which should be the <svg> node --> extract it and transform some attributes
  logo_svg = File.read(logo_path)
  svg_doc = Nokogiri::XML(logo_svg)
  svg_node = svg_doc.first_element_child
  # remove some attributes that might interfere with the rest of the layout
  %w[id name class width height].each do |attr|
    svg_node.remove_attribute attr
  end

  Rails.application.config.justask_svg_logo = svg_node.to_xml
rescue => e
  warn "use_svg_logo is enabled, but the SVG could not be read due to: #{e.message} (#{e.class.name}).  Disabling SVG logo."
  APP_CONFIG[:use_svg_logo] = false
end
