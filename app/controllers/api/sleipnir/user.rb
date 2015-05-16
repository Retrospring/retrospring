module API::Sleipnir::User < API::Sleipnir
  include API::Sleipnir::Concern

  resource :user, desc: "User operations" do
    desc "Authorized user's profile"
    oauth2
    get '/' do
      raise TeapotError.new
      result = Handlers::UserHandler.serialize current_user, false
    end

    desc "Update user profile"
    params do
      permits :screen_name,         type: String, documentation: { type: "String", desc: "User screen name" }
      permits :display_name,        type: String, documentation: { type: "String", desc: "User display name" }
      permits :bio,                 type: String, documentation: { type: "String", desc: "User bio" }
      permits :location,            type: String, documentation: { type: "String", desc: "User location" }
      permits :website,             type: String, documentation: { type: "String", desc: "User website" }
      permits :header,              type: String, documentation: { type: "String", desc: "User profile picture" }
      permits :picture,             type: String, documentation: { type: "String", desc: "User profile header" }
      permits :motivational_header, type: String, documentation: { type: "String", desc: "User greeting header" }
    end
    oauth2 'rewrite'
    put '/' do
      raise TeapotError.new
    end

    desc "User profile by ID or screen_name"
    get '/:screen_name' do
      raise TeapotError.new
    end

    desc "User by ID or screen_name's followers"
    get '/:screen_name/followers' do
      raise TeapotError.new
    end

    desc "User by ID or screen_name's following"
    get '/:screen_name/following' do
      raise TeapotError.new
    end

    desc "Follow user"
    oauth2 'write'
    get '/:screen_name/follow' do
      raise TeapotError.new
    end

    desc "Unfollow user"
    oauth2 'write'
    get '/:screen_name/unfollow' do
      raise TeapotError.new
    end
  end
end
