# frozen_string_literal: true

class MuteRulePolicy
  attr_reader :user, :mute_rule

  def initialize(user, mute_rule)
    @user = user
    @mute_rule = mute_rule
  end

  def destroy?
    user == mute_rule.user || user.admin?
  end
end
