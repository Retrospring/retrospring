RSpec.describe "API::Sleipnir::UserAPI" do
  before :all do
    @me = FactoryGirl.create :user
    @app, @oa, @token = gen_oa_b @me
    @other = FactoryGirl.create :user
    @other_token = gen_oa_pair @oa, gen_oa_token(@app, @other)
  end

  after :all do
    Warden.test_reset!
  end

  it 'GET /user/me.json should return 200 with authentication' do
    res = oa_get @token, '/api/sleipnir/user/me.json'

    expect(res.status).to eq(200)

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /user/timeline.json should return 200 with authentication' do
    res = oa_get @token, '/api/sleipnir/user/timeline.json'

    expect(res.status).to eq(200)

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /user/public.json should return 200 with authentication' do
    res = oa_get @token, '/api/sleipnir/user/public.json'

    expect(res.status).to eq(200)

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /user/public.json should have a post' do
    # TODO: create answer

    res = oa_get @token, '/api/sleipnir/user/public.json'

    expect(res.status).to eq(200)

    body = JSON.parse res.body

    oa_basic_test body

    # expect(body["result"]["api_collection_count"]).to be > 0
  end

  it 'GET /user/1/profile.json should return 200 with authentication' do
    res = oa_get @token, '/api/sleipnir/user/1/profile.json'

    expect(res.status).to eq(200)

    body = JSON.parse res.body

    oa_basic_test body
  end
end
