# frozen_string_literal: true

module ApplicationHelper
  include ApplicationHelper::GraphMethods
  include ApplicationHelper::TitleMethods

  def privileged?(user)
    !current_user.nil? && ((current_user == user) || current_user.mod?)
  end

  def rails_admin_path_for_resource(resource)
    [rails_admin_path, resource.model_name.param_key, resource.id].join("/")
  end
end
