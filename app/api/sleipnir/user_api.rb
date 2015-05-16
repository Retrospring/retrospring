class Sleipnir::UserAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  resource :user, desc: "Operations about the current user" do
    desc "Current user's profile"
    oauth2 'public'
    get do
      raise TeapotError.new
    end
  end
end
