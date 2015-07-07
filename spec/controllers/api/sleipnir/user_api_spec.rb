RSpec.describe "API::Sleipnir::UserAPI" do
  it 'GET /user/me.json should return 200 with authentication' do
    me = FactoryGirl.create :user
    token = gen_oa_b me

    res = oa_get token, '/api/sleipnir/user/me.json'

    expect(res.status).to eq(200)
  end
end
