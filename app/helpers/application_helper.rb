module ApplicationHelper
  def nav_entry(body, path, options = {})
    options = {
      badge: nil,
      badge_color: nil,
      icon: nil
    }.merge(options)

    unless options[:icon].nil?
      body = "#{content_tag(:i, '', class: "mdi-#{options[:icon]}")} #{body}"
    end
    unless options[:badge].nil?
      # TODO: make this prettier?
      body << " #{
        content_tag(:span, options[:badge], class: ("badge#{
          " badge-#{options[:badge_color]}" unless options[:badge_color].nil?
        }"))}"
    end

    content_tag(:li, link_to(body.html_safe, path), class: ('active' if current_page? path))
  end
  
  ##
  # 
  def bootstrap_color c
    case c
    when "error", "alert"
      "danger"
    when "notice"
      "info"
    else
      c
    end
  end

  def inbox_count
    return 0 unless user_signed_in?
    count = Inbox.select("COUNT(id) AS count")
                 .where(new: true)
                 .where(user_id: current_user.id)
                 .group(:user_id)
                 .order(:count)
                 .first
    return nil if count.nil?
    return nil unless count.count > 0
    count.count
  end

  def privileged?(user)
    (current_user && (current_user == user || current_user.admin?)) ? true : false
  end

  def gravatar_url(user)
    return '//www.gravatar.com/avatar' if user.nil?
    "//www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email)}"
  end
end
