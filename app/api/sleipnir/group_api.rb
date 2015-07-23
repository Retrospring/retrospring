class Sleipnir::GroupAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :group do
    desc "List group IDs"
    oauth2 'public'
    throttle hourly: 72
    get '/', as: :groups_api do
      collection = since_id Group, 'user_id = ?', [current_user.id]
      represent_collection collection, with: Sleipnir::Entities::GroupsEntity
    end

    desc "View group timeline"
    oauth2 'public'
    throttle hourly: 72
    get '/:id', as: :group_api do
      group = current_user.groups.find params[:id]
      if group.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_GROUP_NOT_FOUND"})
      end

      collection = since_id Answer, 'user_id in (?)', [group.members.pluck(:user_id)]
      represent_collection collection, with: Sleipnir::Entities::AnswersEntity
    end

    desc "Delete group"
    oauth2 'write'
    throttle hourly: 72
    delete '/:id', as: :delete_group_api do
      group = current_user.groups.find params[:id]
      if group.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_GROUP_NOT_FOUND"})
      end

      group.destroy!
      status 204
    end

    desc "View group members"
    oauth2 'public'
    throttle hourly: 72
    get '/:id/members', as: :group_members_api do
      group = current_user.groups.find params[:id]
      if group.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_GROUP_NOT_FOUND"})
      end

      collection = since_id GroupMember, 'group_id = ?', [group.id]
      represent_collection collection, with: Sleipnir::Entities::GroupMembersEntity
    end

    desc 'Create a group'
    oauth2 'write'
    throttle hourly: 72
    params do
      requires :name, type: String
      requires :display_name, type: String
    end
    post '/', as: :create_group_api do
      group = Group.create user: current_user, name: params[:name], display_name: params[:display_name]
      if group.nil?
        status 400
        return present({success: false, code: 400, result: "ERR_GROUP_CREATE_FAIL"})
      end

      status 201
      return present({success: true, code: 201, result: group.id})
    end

    desc "Add a user to group"
    oauth2 'write'
    throttle hourly: 72
    post '/:id/user/:user_id', as: :mov_group_api do
      group = current_user.groups.find params[:id]
      if group.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_GROUP_NOT_FOUND"})
      end

      user = User.find params[:user_id]
      if user.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      group.add_member user if group.members.find_by_user_id(user.id).nil?

      status 201
      return present({success: true, code: 201, result: "GROUP_USER_ADDED"})
    end

    desc "Remove a user from group"
    oauth2 'write'
    throttle hourly: 72
    delete '/:id/user/:user_id', as: :pop_group_api do
      group = current_user.groups.find params[:id]
      if group.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_GROUP_NOT_FOUND"})
      end

      user = User.find params[:user_id]
      if user.nil?
        status 404
        return present({success: false, code: 404, result: "ERR_USER_NOT_FOUND"})
      end

      group.remove_member user unless group.members.find_by_user_id(user.id).nil?

      status 204
      return
    end
  end
end
