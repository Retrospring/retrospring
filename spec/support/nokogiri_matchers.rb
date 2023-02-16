# frozen_string_literal: true

module NokogiriMatchers
  RSpec::Matchers.matcher :have_css do |css|
    description { %(have at least one element matching the CSS selector #{css.inspect}) }

    match do |rendered|
      Nokogiri::HTML.parse(rendered).css(css).size.positive?
    end
  end
end

RSpec.configure do |c|
  c.include NokogiriMatchers, view: true
end
