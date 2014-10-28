module ApplicationHelper
  def nav_entry(body, path, options={})
    options = {class: "", icon: "", label: "", label_color: "red"}.merge options
    body = semantic_icon(options[:icon]) + " " + body unless options[:icon].empty?
    body = body + " " +  content_tag(:div, options[:label], class: "ui #{options[:label_color]} label") unless options[:label].empty?
    link_to(body, path, class: "#{'active' if current_page? path} item #{options[:class]}")
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
