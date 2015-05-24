class AddOauthApplicationIdToModels < ActiveRecord::Migration
  def change
    add_column :answers, :application_id, :integer, default: nil
    add_column :comments, :application_id, :integer, default: nil
    add_column :questions, :application_id, :integer, default: nil
    add_column :smiles, :application_id, :integer, default: nil
    add_column :comment_smiles, :application_id, :integer, default: nil
  end
end
