# frozen_string_literal: true

namespace :locale do
  desc "Generate en-xx locale"
  task generate: :environment do
    def destroy(val)
      val
        .gsub("A", "ÅÄ")
        .gsub("E", "ÉÊ")
        .gsub("I", "ÏÍ")
        .gsub("O", "ÖØ")
        .gsub("U", "ÜǓ")
        .gsub("a", "åä")
        .gsub("e", "éê")
        .gsub("i", "ïí")
        .gsub("o", "öø")
        .gsub("u", "üǔ")
    end

    def repair(val)
      val
        .gsub("ÅÄ", "A")
        .gsub("ÉÊ", "E")
        .gsub("ÏÍ", "I")
        .gsub("ÖØ", "O")
        .gsub("ÜǓ", "U")
        .gsub("åä", "a")
        .gsub("éê", "e")
        .gsub("ïí", "i")
        .gsub("öø", "o")
        .gsub("üǔ", "u")
    end

    def transform_locale(hash)
      hash.transform_values do |val|
        next transform_locale(val) if val.is_a? Hash
        next val if val.is_a? Symbol

        val = destroy(val)

        # undo damage in %{variables}
        val = val.gsub(/%{([^}]+)}/) { repair(_1) }

        # undo damage in <html tags>
        val = val.gsub(/<([^>]+)>/) { repair(_1) }

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
