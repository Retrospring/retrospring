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
    puts current_user.id
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
end
