class Ajax::ReportController < AjaxController
  def create
    params.require :id
    params.require :type

    @response[:status] = :err

    if current_user.nil?
      @response[:message] = I18n.t('messages.report.create.login')
      return
    end

    unless %w(answer comment question user).include? params[:type]
      @response[:message] = I18n.t('messages.report.create.unknown')
      return
    end

    obj = params[:type].strip.capitalize

    object = case obj
      when 'User'
        User.find_by_screen_name! params[:id]
      when 'Question'
        Question.find params[:id]
      when 'Answer'
        Answer.find params[:id]
      when 'Comment'
        Comment.find params[:id]
      else
        Answer.find params[:id]
      end

    if object.nil?
      @response[:message] = I18n.t('messages.report.create.not_found', parameter: params[:type])
      return
    end

    current_user.report object, params[:reason]

    @response[:status] = :okay
    @response[:message] = I18n.t('messages.report.create.okay', parameter: params[:type])
    @response[:success] = true
  end
end
