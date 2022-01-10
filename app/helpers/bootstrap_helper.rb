module BootstrapHelper
  def nav_entry(body, path, options = {})
    options = {
      badge: nil,
      badge_color: nil,
      icon: nil,
      class: ''
    }.merge(options)

    classes = [
      "nav-item",
      current_page?(path) ? "active" : nil,
      options[:class]
    ].compact.join(" ")

    unless options[:icon].nil?
      if options[:icon_only]
        body = "#{content_tag(:i, '', class: "fa fa-#{options[:icon]}", title: body)}"
      else
        body = "#{content_tag(:i, '', class: "fa fa-#{options[:icon]}")} #{body}"
      end
    end
    unless options[:badge].nil?
      badge_class = "badge"
      badge_class << " badge-#{options[:badge_color]}" unless options[:badge_color].nil?
      badge_class << " badge-pill" if options[:badge_pill]
      body += " #{content_tag(:span, options[:badge], class: badge_class)}"
    end

    content_tag(:li, link_to(body.html_safe, path, class: "nav-link"), class: classes)
  end

  def list_group_item(body, path, options = {})
    options = {
      badge: nil,
      badge_color: nil,
      class: ''
    }.merge(options)

    classes = [
      "list-group-item",
      "list-group-item-action",
      current_page?(path) ? "active" : nil,
      options[:class]
    ].compact.join(" ")

    unless options[:badge].nil? or options[:badge] == 0
      # TODO: make this prettier?
      body << " #{
        content_tag(:span, options[:badge], class: ("badge#{
          " badge-#{options[:badge_color]}" unless options[:badge_color].nil?
        }"))}"
    end

    content_tag(:a, body.html_safe, href: path, class: classes)
  end

  def tooltip(body, tooltip_content, placement = "bottom")
    content_tag(:span, body, {title: tooltip_content, "data-toggle" => "tooltip", "data-placement" => placement} )
  end

  def time_tooltip(subject, placement = "bottom")
    tooltip time_ago_in_words(subject.created_at), localize(subject.created_at), placement
  end

  def hidespan(body, hide)
    content_tag(:span, body, class: hide)
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