class Ajax::AnonymousBlockController < AjaxController
  def create
    params.require :question

    question = Question.find(params[:question])

    AnonymousBlock.create!(
      user:       current_user,
      identifier: AnonymousBlock.get_identifier(question.author_identifier),
      question:   question,
    )

    question.inboxes.first.destroy

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.block.create.okay')
    @response[:success] = true

  rescue Errors::Base => e
    @response[:status] = e.code
    @response[:message] = I18n.t(e.locale_tag)
    @response[:success] = false
  end
end
