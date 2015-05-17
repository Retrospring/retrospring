class Oauth::AuthorizedApplicationsController < Doorkeeper::AuthorizedApplicationsController
  layout "application"


  def index
    super
    render "settings/oauth_proxy", locals: { title: "App Access", template: "doorkeeper/authorized_applications/index" }
  end
end
