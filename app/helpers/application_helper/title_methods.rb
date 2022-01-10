module ApplicationHelper::TitleMethods
  include MarkdownHelper
  include UserHelper

  def generate_title(name, junction = nil, content = nil, s = false)
    if s
      if name[-1].downcase != "s"
        name = name + "'s"
      else
        name = name + "'"
      end
    end

    list = [name]

    list.push junction unless junction.nil?

    unless content.nil?
      content = strip_markdown(content)
      if content.length > 45
        content = content[0..42] + "..."
      end
      list.push content
    end
    list.push "|", APP_CONFIG['site_name']

    list.join " "
  end

  def question_title(question)
    name = user_screen_name question.user, anonymous: question.author_is_anonymous, url: false
    generate_title name, "asked", question.content
  end

  def answer_title(answer)
    name = user_screen_name answer.user, anonymous: false, url: false
    generate_title name, "answered", answer.question.content
  end

  def user_title(user, junction = nil)
    name = user_screen_name user, anonymous: false, url: false
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