class Sleipnir::SettingAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :setting do
    desc "Update user's avatar"
    oauth2 'rewrite'
    throttle hourly: 72
    params do
      requires :profile_picture, type: Hashie::Mash
      requires :crop_x,          type: Fixnum
      requires :crop_y,          type: Fixnum
      requires :crop_w,          type: Fixnum
      requires :crop_h,          type: Fixnum
    end
    patch '/avatar' do
      if current_user.update_attributes(params)
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
      requires :profile_header, type: Hashie::Mash
      requires :crop_h_x,       type: Fixnum
      requires :crop_h_y,       type: Fixnum
      requires :crop_h_w,       type: Fixnum
      requires :crop_h_h,       type: Fixnum
    end
    patch '/header' do
      if current_user.update_attributes(params)
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
    patch '/basic' do
      if current_user.update_attributes(params)
        status 202
        return present({success: true, code: 202, result: "BASIC_HEADER"})
      end
      status 400
      return present({success: false, code: 400, result: "ERR_BASIC_QQ"})
    end
  end
end
