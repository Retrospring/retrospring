class AddInputAndOutlineToTheme < ActiveRecord::Migration[4.2]
  def change
    add_column :themes, :input_color, :integer, default: 0xFFFFFF, null: false
    add_column :themes, :input_text, :integer, default: 0x000000, null: false
    add_column :themes, :outline_color, :integer, default: 0x5E35B1, null: false
  end
end
