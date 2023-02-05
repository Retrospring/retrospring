# frozen_string_literal: true

module User::SharingMethods
  def display_sharing_custom_url
    URI(sharing_custom_url).host
  end
end
