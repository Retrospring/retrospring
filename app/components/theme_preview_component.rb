# frozen_string_literal: true

class ThemePreviewComponent < ApplicationComponent
  delegate :id, :to_css, to: :@theme

  def initialize(theme)
    @theme = theme
  end

  def name
    return @theme.name if @theme.name.present?

    @theme.user_id ? t('.unnamed') : t('.default')
  end
end
