class Oauth::ApplicationsController < Doorkeeper::ApplicationsController
  before_filter :authenticate_user!
  before_filter :app_owner!, only: %i(show update)

  layout "application"

  def index
    @applications = current_user.oauth_applications
    render "settings/oauth_proxy", locals: { title: "Applications", template: "doorkeeper/applications/index" }
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

  def update
    if @application.update_attributes(application_params)
      flash[:notice] = I18n.t(:notice, scope: [:doorkeeper, :flash, :applications, :update])
      redirect_to oauth_application_url(@application)
    else
      render "settings/oauth_proxy", locals: { title: "Edit #{@application.name}", template: "doorkeeper/applications/edit" }
    end
  end

  def edit
    render "settings/oauth_proxy", locals: { title: "Edit #{@application.name}", template: "doorkeeper/applications/edit" }
  end

  def show
    render "settings/oauth_proxy", locals: { title: @application.name, template: "doorkeeper/applications/show" }
  end

  def new
    super
    render "settings/oauth_proxy", locals: { title: @application.name, template: "doorkeeper/applications/new" }
  end

  protected

  def app_owner!
    raise ActiveRecord::RecordNotFound unless @application.owner == current_user
  end

  def application_params
    params.require(:doorkeeper_application).permit(:name, :description, :redirect_uri)
  end
end
