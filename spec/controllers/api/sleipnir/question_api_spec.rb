RSpec.describe "API::Sleipnir::QuestionAPI" do
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

  it 'DELETE /sleipnir/question/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)

    res = oa_delete @token, "/api/sleipnir/question/#{question.id}.json"

    expect(res.status).to be < 400
  end

  it 'POST /sleipnir/question/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)

    res = oa_post @token, "/api/sleipnir/question/#{question.id}.json", answer: "This is an answer"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end
end
