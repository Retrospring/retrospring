class Ajax::MuteRuleController < AjaxController
  def create
    params.require :muted_phrase

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    rule = MuteRule.create!(user: current_user, muted_phrase: params[:muted_phrase])
    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = "Rule added successfully."
    @response[:id] = rule.id
  end

  def update
    params.require :id
    params.require :muted_phrase

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    rule = MuteRule.find(params[:id])

    if rule.user_id != current_user.id
      @response[:status] = :nopriv
      @response[:message] = "Can't edit other people's rules"
      return
    end

    rule.muted_phrase = params[:muted_phrase]
    rule.save!

    @response[:status] = :okay
    @response[:message] = "Rule updated successfully."
    @response[:success] = true
  end

  def destroy
    params.require :id

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = I18n.t('messages.noauth')
      return
    end

    rule = MuteRule.find(params[:id])

    if rule.user_id != current_user.id
      @response[:status] = :nopriv
      @response[:message] = "Can't edit other people's rules"
      return
    end

    rule.destroy!

    @response[:status] = :okay
    @response[:message] = "Rule deleted successfully."
    @response[:success] = true
  end
end
