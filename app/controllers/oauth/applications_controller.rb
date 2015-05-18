class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  before_filter :app_owner!, only: %i(show update edit destroy)

  layout "oauth"

  def index
    @applications = current_user.oauth_applications
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    # TODO: Scope grants
    @application.scopes = "public write rewrite moderation"
    # TODO: @application.icon = params[:icon]
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_path(@application)
    else
      redirect_to new_oauth_application_path
    end
  end

  protected

  def app_owner!
    raise ActiveRecord::RecordNotFound unless @application.owner == current_user
  end

  def application_params
    params.require(:doorkeeper_application).permit(:name, :description, :redirect_uri)
  end
end
