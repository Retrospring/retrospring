APP_LOCALES = {}
# locale_str: [language, country code]
# generate list
I18n.with_locale("") do
  locale_map = YAML.load(File.open Rails.root.join("config/hl_to_cc.yml"))
  flag_map = YAML.load(File.open Rails.root.join("config/flags.yml"))
  Dir.glob(Rails.root.join("config/locales/*.yml")).each do |locale|
    l = locale.split("/").last.split(".").first.downcase
    if APP_LOCALES[l].nil?
      cc = l.split '-'
      if cc.length == 1
        cc = cc.first.split '_'
      end
      cc = cc.last

      if flag_map.index(cc).nil? and not locale_map[cc].nil?
        cc = locale_map[cc]
      end

      begin
        lang = I18n.translate("#{l}.language")
        lang = cc if lang.index "translation missing"
        APP_LOCALES[l] = [lang, cc]
      rescue
        APP_LOCALES[l] = [cc, cc]
      end
    end
  end
end
