class ShareWorker
  include Sidekiq::Worker

  sidekiq_options queue: :share

  def perform(answer_id)
    # fuck this… for now
  end
end