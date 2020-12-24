# allow webpack-dev-server host as allowed origin for connect-src
policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?