class Ajax::QuestionController < ApplicationController
  include MarkdownHelper

  rescue_from(ActionController::ParameterMissing) do |param_miss_ex|
    @status = :parameter_error
    @message = "#{param_miss_ex.param.capitalize} is required"
    @success = false
    render partial: "ajax/shared/status"
  end

  def destroy
    params.require :question

    question = Question.find params[:question]
    if question.nil?
      @status = :not_found
      @message = "Question does not exist"
      @success = false
      return
    end

    if not (current_user.mod? or question.user == current_user)
      @status = :not_authorized
      @message = "You are not allowed to delete this question"
      @success = false
      return
    end

    question.destroy!

    @status = :okay
    @message = "Successfully deleted question."
    @success = true
  end

  def create
    params.require :question
    params.require :anonymousQuestion
    params.require :rcpt

    begin
      question = Question.create!(content: params[:question],
                                  author_is_anonymous: params[:anonymousQuestion],
                                  user: current_user)
    rescue ActiveRecord::RecordInvalid
      @status = :rec_inv
      @message = "Your question is too long."
      @success = false
      return
    end

    unless current_user.nil?
      current_user.increment! :asked_count unless params[:anonymousQuestion] == 'true'
    end

    if params[:rcpt] == 'followers'
      unless current_user.nil?
        current_user.followers.each do |f|
          Inbox.create!(user_id: f.id, question_id: question.id, new: true)
        end
      end
    elsif params[:rcpt].start_with? 'grp:'
      unless current_user.nil?
        begin
          current_user.groups.find_by_name!(params[:rcpt].sub 'grp:', '').members.each do |m|
            Inbox.create!(user_id: m.user.id, question_id: question.id, new: true)
          end
        rescue ActiveRecord::RecordNotFound
          @status = :not_found
          @message = "Group not found"
          @success = false
          return
        end
      end
    else
      Inbox.create!(user_id: params[:rcpt], question_id: question.id, new: true)
    end

    @status = :okay
    @message = "Question asked successfully."
    @success = true
  end

  def preview
    params.require :md

    @message = "Failed to render markdown."
    begin
      @markdown = markdown(params[:md], Time.new)
      @message = "Successfully rendered markdown."
    rescue
      @status = :fail
      @success = false
      return
    end
    @status = :okay
    @success = true
  end
end
