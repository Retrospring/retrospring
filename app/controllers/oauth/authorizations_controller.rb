class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  @SCOPES = {
    public: "read your inbox and notifications",
    write: "post questions, answers and comments on your behalf",
    rewrite: "edit your settings",
    moderation: "manage moderation"
  }

  layout "application"
end
