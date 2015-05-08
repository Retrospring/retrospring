class TwitteredMarkdown < Redcarpet::Render::StripDown

  def preprocess(text)
    wrap_mentions(text)
  end

  def wrap_mentions(text)
    text.gsub! /(^|\s)@([a-zA-Z0-9_]{1,16})/ do
      local_user = User.find_by_screen_name($2)
      if local_user.nil?
        "#{$1}#{$2}"
      else
        service = local_user.services.where(type: "Services::Twitter").first
        if service.nil?
          "#{$1}#{$2}"
        else
          "#{$1}@#{service.nickname}"
        end
      end
    end
    text
  end
end
