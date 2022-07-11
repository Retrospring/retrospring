# frozen_string_literal: true

module SharedMarkers
  include ActionView::Helpers::TagHelper

  def process_link(link, text = nil)
    href = if ALLOWED_HOSTS_IN_MARKDOWN.include?(URI(link).host) || URI(link).relative?
             link
           else
             linkfilter_path(url: link)
           end

    options = { href: href }

    unless URI(link).relative?
      options = options.merge({
                                target: "_blank",
                                rel:    "nofollow"
                              })
    end

    # Marking the text content as HTML safe as <tt>content_tag</tt> already escapes it for us
    content_tag(:a, text.nil? ? link : text.html_safe, options)
  rescue
    link
  end

  def autolink(link, _link_type)
    process_link(link)
  end

  def link(link, _title, content)
    process_link(link, content)
  end
end
