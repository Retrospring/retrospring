RSpec.describe "API::Sleipnir::AnswerAPI" do
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

  it "DELETE /sleipnir/answer/:id should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)

    res = oa_delete @token, "/api/sleipnir/answer/#{answer.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it "POST /sleipnir/answer/:id/comments should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)

    res = oa_post @token, "/api/sleipnir/answer/#{answer.id}/comments.json", comment: "This is a comment"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it "DELETE /sleipnir/answer/:id/comments/:id should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)
    comment = Comment.create(content: "This is a comment.", user: @me, answer: answer)

    res = oa_delete @token, "/api/sleipnir/answer/#{answer.id}/comments/#{comment.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it "POST /sleipnir/answer/:id/subscribe should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)

    res = oa_post @token, "/api/sleipnir/answer/#{answer.id}/subscribe.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it "DELETE /sleipnir/answer/:id/subscribe should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)
    subscruption = Subscription.create(user: @me, answer: answer)

    res = oa_delete @token, "/api/sleipnir/answer/#{answer.id}/subscribe.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it "POST /sleipnir/answer/:id/comment/:comment_id should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @other, question: question)
    comment = Comment.create(content: "This is a comment.", user: @other, answer: answer)

    res = oa_post @token, "/api/sleipnir/answer/#{answer.id}/comment/#{comment.id}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it "DELETE /sleipnir/answer/:id/comment/:comment_id should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @other, question: question)
    comment = Comment.create(content: "This is a comment.", user: @other, answer: answer)
    smile = CommentSmile.create(user: @me, comment: comment)

    res = oa_delete @token, "/api/sleipnir/answer/#{answer.id}/comment/#{comment.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it "POST /sleipnir/answer/:id/smile should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @other, question: question)

    res = oa_post @token, "/api/sleipnir/answer/#{answer.id}/smile.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it "DELETE /sleipnir/answer/:id/smile should return less than 400" do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @other, question: question)
    smile = Smile.create(user: @me, answer: answer)

    res = oa_delete @token, "/api/sleipnir/answer/#{answer.id}/smile.json"

    expect(res.status).to be < 400

    question.destroy!
  end
end
