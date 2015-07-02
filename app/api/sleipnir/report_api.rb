class Sleipnir::ReportAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :report do
    desc 'Get reports'
    oauth2 'moderation'
    throttle hourly: 72
    get '/' do
      # TODO:
    end

    desc 'Report a user'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/user/:id' do
      # TODO:
    end

    desc 'Report a question'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/question/:id' do
      # TODO:
    end

    desc 'Report a comment'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/comment/:id' do
      # TODO:
    end

    desc 'Report an answer'
    oauth2 'write'
    throttle hourly: 72
    params do
      optional :reason, type: String, default: ''
    end
    post '/answer/:id' do
      # TODO:
    end

    desc 'Get a report'
    oauth2 'moderation'
    throttle hourly: 72
    get '/:id' do
      # TODO:
    end

    desc 'Delete report'
    oauth2 'moderation'
    throttle hourly: 72
    delete '/:id' do
      # TODO:
    end
  end
end
