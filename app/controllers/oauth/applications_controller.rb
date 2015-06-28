class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  before_filter :set_application, only: %i(show update edit destroy regen metrics)
  before_filter :app_owner!, only: %i(show update edit destroy regen metrics)
  before_filter :app_deleted!, only: %i(show update edit destroy regen metrics)

  layout "oauth"

  def index
    @applications = current_user.applications.where(deleted: false)
  end

  def create
    @application = Doorkeeper::Application.new(application_params)
    @application.owner = current_user if Doorkeeper.configuration.confirm_application_owner?
    if @application.save
      flash[:notice] = I18n.t(:notice, :scope => [:doorkeeper, :flash, :applications, :create])
      redirect_to oauth_application_path(@application)
    else
      redirect_to new_oauth_application_path
    end
  end

  def regen
    application = Doorkeeper::Application.find params["id"]
    application.secret = nil
    application.send "generate_secret"
    application.save!
    redirect_to oauth_application_url(application)
  end

  def metrics
    payload = if APP_CONFIG["api"]["metrics"]
      ApplicationMetric.request(params["id"])
    else
      []
    end
    
    render json: payload
  end

  def update
    if application_params["scopes"].length > 0 and Doorkeeper::OAuth::Scopes.from_string(application_params["scopes"]) != @application.scopes
      @application.secret = nil
      @application.send "generate_secret"
    end

    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to oauth_application_url(@application)
    else
      render :edit
    end
  end

  def destroy
    # Don't actually destroy because we need to keep aux data like icon, homepage, description, name.
    # @application.uid = @application.secret = @application.redirect_uri = @application.owner_type = ""
    # @application.scopes = Doorkeeper::OAuth::Scopes.from_string "INVALID"
    # @application.deleted = true
    # @application.owner_id = 0
    # flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :destroy]) if @application.save validate: false
    # redirect_to oauth_applications_url
    super
  end

  protected

  def app_owner!
    raise ActiveRecord::RecordNotFound unless @application.owner == current_user
  end

  def app_deleted!
    raise ActiveRecord::RecordNotFound if @application.deleted
  end

  def application_params
    params.require(:doorkeeper_application).permit(:name, :description, :homepage, :icon, :crop_x, :crop_y, :crop_h, :crop_w, :redirect_uri, :scopes)
  end
end
