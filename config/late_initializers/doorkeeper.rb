Doorkeeper::Application.send :include, Concerns::ApplicationExtension

APP_CONFIG["port"] ||= 80

begin
  ::APP_FAKE_OAUTH = Doorkeeper::Application.new(name: "Web", description: "#{APP_CONFIG["site_name"]} on the internets", homepage: "http#{APP_CONFIG["https"] && "s" || ""}://#{APP_CONFIG["hostname"]}#{APP_CONFIG["port"] && APP_CONFIG["port"] != 80 && ":#{APP_CONFIG["port"]}" || ""}", deleted: false, scopes: "-1")
  ::APP_FAKE_OAUTH.readonly!
rescue
end
