class Sleipnir::SettingAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :setting do
    desc "Update user's avatar"
    oauth2 'rewrite'
    throttle hourly: 72
    params do
      # Encoding::UndefinedConversionError: "\x89" from ASCII-8BIT to UTF-8
      requires :avatar, type: Rack::Multipart::UploadedFile
      requires :crop_x, type: Fixnum
      requires :crop_y, type: Fixnum
      requires :crop_w, type: Fixnum
      requires :crop_h, type: Fixnum
    end
    patch '/avatar', as: :update_avatar_api do
      if true # can't test, unsure about this so it's blocked.
        status 410
        return present({success: false, code: 410, result: "ENDPOINT_GONE"})
      end

      obj = {
        profile_picture: params["avatar"],
        crop_x:          params["crop_x"],
        crop_y:          params["crop_y"],
        crop_w:          params["crop_w"],
        crop_h:          params["crop_h"]
      }

      if current_user.update_attributes(obj)
        status 202
        return present({success: true, code: 202, result: "AVATAR_UPDATE"})
      end
      status 400
      return present({success: false, code: 400, result: "ERR_AVATAR_QQ"})
    end

    desc "Update user's header"
    oauth2 'rewrite'
    throttle hourly: 72
    params do
      # Encoding::UndefinedConversionError: "\x89" from ASCII-8BIT to UTF-8
      requires :header, type: Rack::Multipart::UploadedFile
      requires :crop_x, type: Fixnum
      requires :crop_y, type: Fixnum
      requires :crop_w, type: Fixnum
      requires :crop_h, type: Fixnum
    end
    patch '/header', as: :update_header_api do
      if true # can't test, unsure about this so it's blocked.
        status 410
        return present({success: false, code: 410, result: "ENDPOINT_GONE"})
      end

      obj = {
        profile_header: params["header"],
        crop_h_x:       params["crop_x"],
        crop_h_y:       params["crop_y"],
        crop_h_w:       params["crop_w"],
        crop_h_h:       params["crop_h"]
      }

      if current_user.update_attributes(obj)
        status 202
        return present({success: true, code: 202, result: "HEADER_UPDATE"})
      end
      status 400
      return present({success: false, code: 400, result: "ERR_HEADER_QQ"})
    end

    desc "Update user's basic info"
    oauth2 'rewrite'
    throttle hourly: 72
    params do
      optional :display_name,      type: String, default: nil
      optional :motivation_header, type: String, default: nil
      optional :website,           type: String, default: nil
      optional :location,          type: String, default: nil
      optional :bio,               type: String, default: nil
    end
    patch '/basic', as: :update_info_api do
      obj = {}

      obj["display_name"] = params["display_name"] unless params["display_name"].nil?
      obj["motivation_header"] = params["motivation_header"] unless params["motivation_header"].nil?
      obj["website"] = params["website"] unless params["website"].nil?
      obj["location"] = params["location"] unless params["location"].nil?
      obj["bio"] = params["bio"] unless params["bio"].nil?

      if current_user.update_attributes(obj)
        status 205
        return present({success: true, code: 202, result: "BASIC_UPDATE"})
      end
      status 400
      return present({success: false, code: 400, result: "ERR_BASIC_QQ"})
    end
  end
end
