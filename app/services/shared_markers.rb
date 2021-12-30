module SharedMarkers
  def autolink(link, _link_type)
    if ALLOWED_HOSTS.include? URI(link).host
      return "<a href=\"#{link}\" target=\"_blank\">#{link}</a>"
    end

    "<a href=\"#{linkfilter_path(url: link)}\" target=\"_blank\">#{link}</a>"
  end
end