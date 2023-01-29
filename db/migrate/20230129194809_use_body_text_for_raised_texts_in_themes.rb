# frozen_string_literal: true

class UseBodyTextForRaisedTextsInThemes < ActiveRecord::Migration[6.1]
  def change
    execute <<~SQUIRREL
      UPDATE themes
      SET raised_text = body_text,
          raised_accent_text = body_text
      WHERE body_text != 0;
    SQUIRREL
  end
end
