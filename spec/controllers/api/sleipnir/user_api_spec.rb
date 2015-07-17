RSpec.describe "API::Sleipnir::UserAPI" do
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

  it 'PATCH /sleipnir/user/notifications/:id should return less than 400' do
    question     = Question.create(content: 'This is a question.', user: @me)
    answer       = Answer.create(content: 'This is an answer.', user: @me, question: question)
    notification = Notification.create(recipient: @me, target: answer)

    res = oa_patch @token, "/api/sleipnir/user/notifications/#{notification.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'PATCH /sleipnir/user/inbox/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    inbox    = Inbox.create(user: @me, question: question)

    res = oa_patch @token, "/api/sleipnir/user/inbox/#{inbox.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'DELETE /sleipnir/user/inbox should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    inbox    = Inbox.create(user: @me, question: question)

    res = oa_delete @token, "/api/sleipnir/user/inbox.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'DELETE /sleipnir/user/inbox/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    inbox    = Inbox.create(user: @me, question: question)

    res = oa_delete @token, "/api/sleipnir/user/inbox/#{inbox.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'POST /sleipnir/user/:id/ask should return less than 400' do
    res = oa_post @token, "/api/sleipnir/user/#{@me.id}/ask.json", question: "This is a question."

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'POST /sleipnir/user/me/ask should return less than 400' do
    res = oa_post @token, "/api/sleipnir/user/me/ask.json", question: "This is a question."

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'POST /sleipnir/user/:id/follow should return less than 400' do
    res = oa_post @token, "/api/sleipnir/user/#{@other.id}/follow.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'DELETE /sleipnir/user/:id/follow should return less than 400' do
    res = oa_delete @token, "/api/sleipnir/user/#{@other.id}/follow.json"

    expect(res.status).to be < 400
  end

  it 'POST /sleipnir/user/:id/ban should return less than 400' do
    res = oa_post @token, "/api/sleipnir/user/#{@other.id}/ban.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'DELETE /sleipnir/user/:id/ban should return less than 400' do
    res = oa_delete @token, "/api/sleipnir/user/#{@other.id}/ban.json"

    expect(res.status).to be < 400
  end
end
