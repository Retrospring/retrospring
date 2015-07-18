RSpec.describe "API::Sleipnir::GroupAPI" do
  before :all do
    @me               = FactoryGirl.create :user
    @other            = FactoryGirl.create :user

    @me.admin = true
    @me.save!

    @app, @oa, @token = gen_oa_b @me
  end

  after :all do
    Warden.test_reset!
  end

  it 'DELETE /api/sleipnir/group/:id should return less than 400' do
    group = Group.create(user: @me, name: 'group1', display_name: 'This is a group 1')

    res = oa_delete @token, "/api/sleipnir/group/#{group.id}.json"

    expect(res.status).to be < 400
  end

  it 'POST /api/sleipnir/group should return less than 400' do
    res = oa_post @token, "/api/sleipnir/group", {name: "group2", display_name: "This is a group 2"}

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'POST /api/sleipnir/group/:id/user/:id should return less than 400' do
    group = Group.create(user: @me, name: 'group3', display_name: 'This is a group 3')
    res = oa_post @token, "/api/sleipnir/group/#{group.id}/user/#{@other.id}"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    group.destroy!
  end

  it 'DELETE /api/sleipnir/group/:id/user/:id should return less than 400' do
    group = Group.create(user: @me, name: 'group4', display_name: 'This is a group 4')
    member = GroupMember.create(user: @other, group: group)
    res = oa_delete @token, "/api/sleipnir/group/#{group.id}/user/#{@other.id}"

    expect(res.status).to be < 400

    group.destroy!
  end
end
