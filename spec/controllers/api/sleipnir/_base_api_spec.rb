RSpec.describe 'API::Sleipnir' do
  before :all do
    @me                         = FactoryGirl.create :user
    @other                      = FactoryGirl.create :user
    @question                   = Question.create(content: 'This is a question.', user: @me)
    @answer                     = Answer.create(content: 'This is an answer.', user: @me, question: @question)
    @comment                    = Comment.create(content: 'This is a comment.', user: @me, answer: @answer)
    @inbox                      = Inbox.create(user: @me, question: @question, new: true)
    @smile                      = Smile.create(user: @me, answer: @answer)
    @comment_smile              = CommentSmile.create(user: @me, comment: @commnent)
    @report_answer              = Report.create(type: 'Reports::Answer', target_id: @answer.id, user: @me)
    @report_user                = Report.create(type: 'Reports::User', target_id: @me.id, user: @me)
    @report_question            = Report.create(type: 'Reports::Question', target_id: @question.id, user: @me)
    @report_comment             = Report.create(type: 'Reports::Comment', target_id: @comment.id, user: @me)
    @notification_comment       = Notification.create(recipient: @me, target: @comment, new: true)
    @notification_answer        = Notification.create(recipient: @me, target: @answer, new: true)
    @notification_question      = Notification.create(recipient: @me, target: @question, new: true)
    @notification_smile         = Notification.create(recipient: @me, target: @smile, new: true)
    @notification_comment_smile = Notification.create(recipient: @me, target: @comment_smile, new: true)
    @follow_me                  = Relationship.create(source: @me, target: @other)
    @follow_other               = Relationship.create(source: @other, target: @me)
    @moderation_comment         = ModerationComment.create(report: @report_answer, user: @me, content: 'This is a moderation comment')
    @moderation_vote            = ModerationVote.create(report: @report_answer, user: @me, upvote: true)
    @group                      = Group.create(user: @me, name: 'Group', display_name: 'This is a group')
    @group_member               = GroupMember.create(user: @other, group: @group)

    @me.admin = true
    @me.save!

    @other.admin = true
    @other.save!

    @app, @oa, @token = gen_oa_b @me
  end

  after :all do
    Warden.test_reset!
  end

  it 'GET /sleipnir/user/me.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/me.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/timeline.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/timeline.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/public.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/public.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/new.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/new.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/inbox.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/inbox.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/notifications.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/notifications.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/profile.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/profile.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/questions.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/questions.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/answers.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/answers.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/followers.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/followers.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/following.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/following.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/avatar.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/avatar.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/user/:id/header.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/user/1/header.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/question/:id.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/question/1.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/question/:id/answers.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/question/1/answers.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/answer/:id.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/answer/1.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/answer/:id/comments.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/answer/1/comments.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/answer/:id/smile.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/answer/1/smile.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/answer/:id/comment/:comment_id.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/answer/1/comment/1.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/report/:id/comment.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/report/1/comment.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/group.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/group.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/group/:id.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/group/1.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/group/:id/members.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/group/1/members.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/report.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/report.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/report/:id.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/report/1.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/resolve/:screen_name.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/resolve/#{@me.screen_name}.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/admins.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/admins.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/moderators.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/moderators.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/contributors.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/contributors.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/supporters.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/supporters.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/util/stats.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/util/stats.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/aux_test.json should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/aux_test.json"

    expect(res.status).to be < 400

    body = JSON.parse res.body

    oa_basic_test body
  end

  it 'GET /sleipnir/aux_test.msgpack should status less than 400 with authentication' do
    res = oa_get @token, "/api/sleipnir/aux_test.msgpack"

    expect(res.status).to be < 400
  end
end
