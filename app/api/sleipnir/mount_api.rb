class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json

  mount Sleipnir::UserAPI
  mount Sleipnir::QuestionAPI
  mount Sleipnir::AnswerAPI
  mount Sleipnir::ModerationAPI
  mount Sleipnir::GroupAPI
  mount Sleipnir::ReportAPI
  mount Sleipnir::UtilityAPI

  desc "Teapot error test page"
  get "/dummy" do
    raise TeapotError.new
  end
end
