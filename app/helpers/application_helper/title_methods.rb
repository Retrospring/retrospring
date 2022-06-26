# frozen_string_literal: true

module ApplicationHelper::TitleMethods
  include MarkdownHelper
  include UserHelper

  def generate_title(name, junction = nil, content = nil, possessive = false)
    if possessive
      name = if name[-1].downcase == "s"
               "#{name}'"
             else
               "#{name}'s"
             end
    end

    list = [name, junction].compact

    unless content.nil?
      content = strip_markdown(content)
      content = "#{content[0..42]}…" if content.length > 45
      list.push content
    end
    list.push "|", APP_CONFIG["site_name"]

    list.join " "
  end

  def question_title(question)
    context_user = question.answers&.first&.user if question.direct
    name = user_screen_name question.user,
                            context_user:      context_user,
                            author_identifier: question.author_is_anonymous ? question.author_identifier : nil,
                            url:               false
    generate_title name, "asked", question.content
  end

  def answer_title(answer)
    name = user_screen_name answer.user, url: false
    generate_title name, "answered", answer.question.content
  end

  def user_title(user, junction = nil)
    name = user_screen_name user, url: false
    generate_title name, junction, nil, !junction.nil?
  end

  def questions_title(user)
    user_title user, "questions"
  end

  def answers_title(user)
    user_title user, "answers"
  end

  def smiles_title(user)
    user_title user, "smiles"
  end

  def comments_title(user)
    user_title user, "comments"
  end

  def list_title(list)
    generate_title list.name
  end
end
