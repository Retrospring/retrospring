# frozen_string_literal: true

module User::ReactionMethods
  # smiles an answer or comment
  # @param item [ApplicationRecord] the answer/comment to smile
  def smile(item)
    # rubocop:disable Style/RedundantSelf
    raise Errors::ReactingSelfBlockedOther if self.blocking?(answer.user)
    raise Errors::ReactingOtherBlockedSelf if answer.user.blocking?(self)
    # rubocop:enable Style/RedundantSelf

    ::Appendable::Reaction.create!(user: self, parent: item, content: "🙂")
  end

  # unsmile an answer or comment
  # @param item [ApplicationRecord] the answer/comment to unsmile
  def unsmile(item)
    ::Appendable::Reaction.find_by(user: self, parent: item).destroy
  end

  def smiled?(item)
    item.smiles.pluck(:user_id).include? id
  end
end
