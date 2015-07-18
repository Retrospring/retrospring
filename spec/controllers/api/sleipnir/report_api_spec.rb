RSpec.describe "API::Sleipnir::ReportAPI" do
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

  it 'POST /sleipnir/report/:id/comment should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    report = Report.create(target_id: question.id, user: @other, type: "Reports::Question")

    res = oa_post @token, "/api/sleipnir/report/#{report.id}/comment.json", {comment: "This is a report comment"}

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it 'DELETE /sleipnir/report/:id/comment/:comment_id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    report = Report.create(target_id: question.id, user: @other, type: "Reports::Question")
    comment = ModerationComment.create(report: report, user: @me, content: "This is a comment")

    res = oa_delete @token, "/api/sleipnir/report/#{report.id}/comment/#{comment.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'POST /sleipnir/report/:id/vote should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    report = Report.create(target_id: question.id, user: @other, type: "Reports::Question")

    res = oa_post @token, "/api/sleipnir/report/#{report.id}/vote.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it 'DELETE /sleipnir/report/:id/vote should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    report = Report.create(target_id: question.id, user: @other, type: "Reports::Question")

    res = oa_delete @token, "/api/sleipnir/report/#{report.id}/vote.json"

    expect(res.status).to be < 400

    question.destroy!
  end

  it 'POST /sleipnir/report/user/:id should return less than 400' do
    res = oa_post @token, "/api/sleipnir/report/user/#{@other.id}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'POST /sleipnir/report/question/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)

    res = oa_post @token, "/api/sleipnir/report/question/#{question.id}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it 'POST /sleipnir/report/answer/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)

    res = oa_post @token, "/api/sleipnir/report/answer/#{answer.id}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it 'POST /sleipnir/report/comment/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    answer = Answer.create(content: "This is a question.", user: @me, question: question)
    comment = Comment.create(content: "This is a comment.", user: @me, answer: answer)

    res = oa_post @token, "/api/sleipnir/report/comment/#{comment.id}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body

    question.destroy!
  end

  it 'DELETE /sleipnir/report/:id should return less than 400' do
    question = Question.create(content: 'This is a question.', user: @me)
    report = Report.create(target_id: question.id, user: @other, type: "Reports::Question")

    res = oa_delete @token, "/api/sleipnir/report/#{report.id}.json"

    expect(res.status).to be < 400

    question.destroy!
  end
end
