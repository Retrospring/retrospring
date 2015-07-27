class QuestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :question, retry: false

  # @param rcpt [String] recipient
  # @param user_id [Integer] user id passed from Devise
  # @param question_id [Integer] newly created question id
  def perform(rcpt, user_id, question_id)
    begin
      user = User.find(user_id)
      if rcpt == 'followers'
        user.followers.each do |f|
          Inbox.create(user_id: f.id, question_id: question_id, new: true)
        end
      elsif rcpt.start_with? 'grp:'
        user.groups.find_by_name!(rcpt.sub 'grp:', '').members.each do |m|
          Inbox.create(user_id: m.user.id, question_id: question_id, new: true)
        end
      else
        logger.info "unknown rcpt #{rcpt}"
      end
    rescue => e
      logger.info "failed to ask question: #{e.message}"
    end
  end
end
