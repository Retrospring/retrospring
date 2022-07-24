class Ajax::MuteRuleController < AjaxController
  def create
    params.require :muted_phrase

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = t(".noauth")
      return
    end

    rule = MuteRule.create!(user: current_user, muted_phrase: params[:muted_phrase])
    @response[:status] = :okay
    @response[:success] = true
    @response[:message] = t(".success")
    @response[:id] = rule.id
  end

  def destroy
    params.require :id

    unless user_signed_in?
      @response[:status] = :noauth
      @response[:message] = t(".noauth")
      return
    end

    rule = MuteRule.find(params[:id])

    if rule.user_id != current_user.id
      @response[:status] = :nopriv
      @response[:message] = t(".nopriv")
      return
    end

    rule.destroy!

    @response[:status] = :okay
    @response[:message] = t(".success")
    @response[:success] = true
  end
end
