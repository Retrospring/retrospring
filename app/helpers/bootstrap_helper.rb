# frozen_string_literal: true

module BootstrapHelper
  def nav_entry(body, path, options = {})
    options = {
      badge:       nil,
      badge_color: nil,
      icon:        nil,
      class:       ""
    }.merge(options)

    classes = [
      "nav-item",
      current_page?(path) ? "active" : nil,
      options[:class]
    ].compact.join(" ")

    unless options[:icon].nil?
      body = if options[:icon_only]
               content_tag(:i, "", class: "fa fa-#{options[:icon]}", title: body).to_s
             else
               "#{content_tag(:i, '', class: "fa fa-#{options[:icon]}")} #{body}"
             end
    end
    unless options[:badge].nil?
      badge_class = [
        "badge",
        ("badge-#{options[:badge_color]}" unless options[:badge_color].nil?),
        ("badge-pill" if options[:badge_pill])
      ].compact.join(" ")

      body += " #{content_tag(:span, options[:badge], class: badge_class)}".html_safe
    end

    content_tag(:li, link_to(body.html_safe, path, class: "nav-link"), class: classes)
  end

  def list_group_item(body, path, options = {})
    options = {
      badge:       nil,
      badge_color: nil,
      class:       ""
    }.merge(options)

    classes = [
      "list-group-item",
      "list-group-item-action",
      current_page?(path) ? "active" : nil,
      options[:class]
    ].compact.join(" ")

    unless options[:badge].nil? || (options[:badge]).zero?
      # TODO: make this prettier?
      body << " #{
        content_tag(:span, options[:badge], class: "badge#{
          " badge-#{options[:badge_color]}" unless options[:badge_color].nil?
        }")}"
    end

    content_tag(:a, body.html_safe, href: path, class: classes)
  end

  def tooltip(body, tooltip_content, placement = "bottom")
    content_tag(:span, body, { :title => tooltip_content, "data-bs-toggle" => "tooltip", "data-bs-placement" => placement })
  end

  def time_tooltip(subject, placement = "bottom")
    tooltip time_ago_in_words(subject.created_at), localize(subject.created_at), placement
  end

  def hidespan(body, hide)
    content_tag(:span, body, class: hide)
  end

  ##
  #
  def bootstrap_color(color)
    case color
    when "error", "alert"
      "danger"
    when "notice"
      "info"
    else
      color
    end
  end
end
