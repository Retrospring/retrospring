module ApiHelpers
  def gen_oa_application(owner = FactoryGirl.create(:user))
    Doorkeeper::Application.create name: "api_#{DateTime.now.to_i}_#{owner.id}_#{owner.screen_name}", owner: owner, redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: gen_oa_scopes(['write', 'public', 'moderation', 'rewrite'])
  end

  def gen_oa_token(application, user, scopes = "public write moderation rewrite")
    Doorkeeper::AccessToken.find_or_create_for application, user.id, scopes, DateTime.tomorrow, false
  end

  def gen_oa_scopes(scopes)
    if scopes.is_a? String
      Doorkeeper::OAuth::Scopes.from_string scopes
    else
      Doorkeeper::OAuth::Scopes.from_array scopes
    end
  end

  def gen_oa(application)
    OAuth2::Client.new application.uid, application.secret, site: "http://127.0.0.1:#{HTTP_PORT}" do |stack|
      stack.request :multipart
      stack.request :url_encoded
      stack.adapter  Faraday.default_adapter
    end
  end

  def gen_oa_pair(oa, token)
    OAuth2::AccessToken.new(oa, token.token)
  end

  def gen_oa_b(user)
    app = gen_oa_application
    token = gen_oa_token app, user
    oa = gen_oa app
    [app, oa, gen_oa_pair(oa, token)]
  end

  def oa_dump(verb, path, res)
    body = begin
      JSON.pretty_generate(JSON.parse(res.body))
    rescue
      Base64.encode64(res.body)
    end

    ["#{verb} #{path} #{res.status}", "#{JSON.pretty_generate(res.headers)}", "#{body}"].join("\n\n")
  end

  def oa_faraday(oa, path)
    res = oa.connection.get path
    file = Rails.root.join 'log', "test/api/GET_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("GET", path, res) }
    res
  end

  def oa_post(token, path, data = {}, body = {})
    res = token.post path, :params => data, :body => body
    file = Rails.root.join 'log', "test/api/POST_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("POST", path, res) }
    res
  end

  def oa_patch(token, path, data = {}, body = {})
    res = token.patch path, :params => data, :body => body
    file = Rails.root.join 'log', "test/api/PATCH_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("PATCH", path, res) }
    res
  end

  def oa_delete(token, path, data = {}, body = {})
    res = token.delete path, :params => data, :body => body
    file = Rails.root.join 'log', "test/api/DELETE_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("DELETE", path, res) }
    res
  end

  def oa_put(token, path, data = {}, body = {})
    res = token.put path, :params => data, :body => body
    file = Rails.root.join 'log', "test/api/PUT_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("PUT", path, res) }
    res
  end

  def oa_get(token, path, data = {}, body = {})
    res = token.get path, :params => data, :body => body
    file = Rails.root.join 'log', "test/api/GET_#{path[1..path.length].gsub(/\d+/, "id").gsub("/", "_")}.resp"
    FileUtils.mkdir_p Rails.root.join 'log', "test/api"
    File.open(file, 'w') { |file| file.write oa_dump("GET", path, res) }
    res
  end

  def oa_basic_test(body)
    expect(body["success"]).not_to be_nil
    expect(body["success"]).to eq(true)
    expect(body["code"]).not_to be_nil
    expect(body["code"]).to be < 400
    expect(body["result"]).not_to be_nil
  end
end
