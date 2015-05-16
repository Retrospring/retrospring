class API < Grape::API
  prefix 'api'
  format :json

  mount Sleipnir::MountAPI => "/"

  route :any, '*path' do
    Rack::Response.new({message: "Not found"}.to_json, 404).finish
  end
end
