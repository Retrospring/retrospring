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
  mount Sleipnir::ReportAPI
  mount Sleipnir::ModerationAPI
  mount Sleipnir::GroupAPI
  mount Sleipnir::UtilityAPI
  mount Sleipnir::SettingAPI

  desc "Error test, designed to test the exception net"
  get "/teapot_test", as: :heres_my_spout_api do
    raise TeapotError.new
  end

  include Sleipnir::Concerns

  desc "Auxiliary test, designed to test formatters and global options"
  get "/aux_test", as: :aux_test_api do
    aux = {
      number: 1,
      time: DateTime.now,
      string: "aux",
      float: Math::PI,
      map: [1,"string",Math::PI],
      dictionary: {a: 1, b: "string", c: Math::PI},
      void: nil
    }

    represent aux, with: Sleipnir::Entities::AuxiliaryTestEntity
  end
end
