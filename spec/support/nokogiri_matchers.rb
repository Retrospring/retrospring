# frozen_string_literal: true

module NokogiriMatchers
  RSpec::Matchers.matcher :have_css do |css|
    description { %(have at least one element matching the CSS selector #{css.inspect}) }

    match do |rendered|
      Nokogiri::HTML.parse(rendered).css(css).size.positive?
    end
  end

  RSpec::Matchers.matcher :have_attribute do |expected_attribute|
    description do
      case expected_attribute
      when Hash
        raise ArgumentError.new("have_attribute only wants one key=>value pair") unless expected_attribute.size == 1

        key = expected_attribute.keys.first
        value = expected_attribute.values.first
        %(have an attribute named #{key.inspect} with a value of #{value.inspect})
      else
        %(have an attribute named #{expected_attribute.inspect})
      end
    end

    match do |element|
      case expected_attribute
      when Hash
        raise ArgumentError.new("have_attribute only wants one key=>value pair") unless expected_attribute.size == 1

        key = expected_attribute.keys.first
        value = expected_attribute.values.first

        element.attr(key.to_s).value == value
      else
        !element.attr(expected_attribute.to_s).nil?
      end
    end
  end
end

RSpec.configure do |c|
  c.include NokogiriMatchers, view: true
end
