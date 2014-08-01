module ApplicationHelper
  def nav_entry(body, path)
    content_tag(:li, link_to(body, path), class: ('active' if current_page? path))
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
end
