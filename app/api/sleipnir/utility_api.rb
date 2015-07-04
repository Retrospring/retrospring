class Sleipnir::UtilityAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :util do
    desc 'Resolve screen name into user profile'
    get '/resolve/:screen_name', as: :resolve_profile_api do
      user = User.find_by_screen_name params[:screen_name]
      if user.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      redirect "/api/sleipnir/user/#{user.id}/profile.json" # boo hoo
    end

    desc 'List admins'
    get '/admins', as: :list_admins_api do
      # collection = User.where('flags & ?', 2 ** FLAGS.index('admin'))
      collection = User.where(admin: true).pluck(:id)
      present({success: true, code: 200, result: {admins: collection}})
    end

    desc 'List moderators'
    get '/moderators', as: :list_mods_api do
      # collection = User.where('flags & ? OR flags & ?', 2 ** FLAGS.index('admin'), 2 ** FLAGS.index('moderator'))
      collection = User.where('admin = ? OR moderator = ?', true, true).pluck(:id)
      present({success: true, code: 200, result: {moderators: collection}})
    end

    desc 'List contributors'
    get '/contributors', as: :list_contrib_api do
      # collection = User.where('flags & ? OR flags & ?', 2 ** FLAGS.index('contributor'), 2 ** FLAGS.index('translator'))
      collection = User.where('contributor = ? OR translator = ?', true, true).pluck(:id)
      present({success: true, code: 200, result: {contributors: collection}})
    end

    desc 'List supporters'
    get '/supporters', as: :list_supporter_api do
      # collection = User.where('flags & ?', 2 ** FLAGS.index('supporter'))
      collection = User.where(supporter: true).pluck(:id)
      present({success: true, code: 200, result: {supporters: collection}})
    end

    desc 'List numbers'
    get '/stats', as: :list_stat_api do
      present({success: true, code: 200, result: {
        question: Question.count,
        answer: Answer.count,
        comment: Comment.count,
        smiles: {
          answer: Smile.count,
          comment: CommentSmile.count
        },
        user: User.count
      }})
    end
  end
end
