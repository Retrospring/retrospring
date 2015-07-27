class QuestionWorker
  include Sidekiq::Worker

  sidekiq_options queue: :question, retry: false

  # @param resource_id [Integer] user id passed from Devise
  def perform(rcpt, user_id, question_id)
    begin
      user = User.find(user_id)
      if params[:rcpt].start_with? 'grp:'
        user.followers.each do |f|
          Inbox.create!(user_id: fid, question_id: question_id, new: true)
        end
      else
        current_user.groups.find_by_name!(params[:rcpt].sub 'grp:', '').members.each do |m|
          Inbox.create!(user_id: m.user.id, question_id: question.id, new: true)
        end
      end
    rescue => e
      Rails.logger.error "failed to answer question: #{e.message}"
    end
  end
end
