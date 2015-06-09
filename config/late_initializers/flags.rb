APP_LOCALES = {}
# locale_str: [language, country code]
# generate list
I18n.with_locale("") do
  locale_map = YAML.load(File.open Rails.root.join("config/hl_to_cc.yml"))
  flag_map = YAML.load(File.open Rails.root.join("config/flags.yml"))
  Dir.glob(Rails.root.join("config/locales/*.yml")).each do |locale|
    l = locale.split("/").last.split(".").first.downcase
    if APP_LOCALES[l].nil?
      cc = l.split("-").last

      if flag_map.index(cc).nil?
        cc = locale_map[cc]
      end

      unless flag_map.index(cc).nil?
        begin
          lang = I18n.translate("#{l}.language")
          lang = '' if lang.index "translation missing"
          APP_LOCALES[l] = [lang, cc]
        rescue I18n.MissingTranslationData
          APP_LOCALES[l] = ['', cc]
        rescue
        end
      end
    end
  end
end
