module SharedMarkers
  include ActionView::Helpers::TagHelper

  def autolink(link, _link_type)
    href = if ALLOWED_HOSTS_IN_MARKDOWN.include?(URI(link).host)
             link
           else
             linkfilter_path(url: link)
           end

    content_tag(:a, link, href: href, target: "_blank", rel: "nofollow")
  rescue
    link
  end
end