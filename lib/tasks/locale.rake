# frozen_string_literal: true

module TestLocaleTransformer
  SUBSTITUTIONS = {
    "a" => "åä",
    "e" => "éê",
    "i" => "ïí",
    "n" => "ñ",
    "o" => "öø",
    "r" => "ř",
    "u" => "üǔ",
    "y" => "ÿ",
    "z" => "ż"
  }.freeze

  refine String do
    def test_locale_destroy
      SUBSTITUTIONS.inject(self) do |val, (from, to)|
        val.gsub(from, to).gsub(from.upcase, to.upcase)
      end
    end

    def test_locale_repair
      SUBSTITUTIONS.inject(self) do |val, (from, to)|
        val.gsub(to, from).gsub(to.upcase, from.upcase)
      end
    end
  end
end

using TestLocaleTransformer

namespace :locale do
  desc "Generate en-xx locale"
  task generate: :environment do
    def transform_locale(hash)
      hash.transform_values do |val|
        next transform_locale(val) if val.is_a? Hash
        next val if val.is_a? Symbol

        val = val.test_locale_destroy

        # undo damage in %{variables}
        val = val.gsub(/%{([^}]+)}/, &:test_locale_repair)

        # undo damage in <html tags>
        val = val.gsub(/<([^>]+)>/, &:test_locale_repair)

        "[#{val}]"
      end
    end

    en_locales = Dir[Rails.root.join("config/locales/*.en.yml")]

    en_locales.each do |locale_path|
      destination = locale_path.sub(/\.en\.yml$/, ".en-xx.yml")
      puts "* generating #{File.basename(destination)}"

      locale = YAML.load_file(locale_path)["en"]
      new_locale = { "en-xx" => transform_locale(locale) }
      File.open(destination, "w") do |f|
        f.puts new_locale.to_yaml
      end
    end
  end
end
