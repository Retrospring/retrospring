class Sleipnir::MountAPI < Grape::API
  format :json
  version :sleipnir, cascade: false
  default_error_formatter :json

  mount Sleipnir::UserAPI
  mount Sleipnir::QuestionAPI
  mount Sleipnir::AnswerAPI

  get "/dummy" do
    raise TeapotError.new
  end
end
