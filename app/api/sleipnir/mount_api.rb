class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json

  desc "Sleipnir (1.0) API"
  get as: :sleipnir_api do
    return present({success: true, code: 200, result: "API_ACTIVE"})
  end

  mount Sleipnir::UserAPI
  mount Sleipnir::QuestionAPI
  mount Sleipnir::AnswerAPI
  mount Sleipnir::ModerationAPI
  mount Sleipnir::GroupAPI
  mount Sleipnir::ReportAPI
  mount Sleipnir::UtilityAPI
  mount Sleipnir::SettingAPI

  desc "Teapot error test page"
  get "/dummy", as: :heres_my_spout_api do
    raise TeapotError.new
  end
end
