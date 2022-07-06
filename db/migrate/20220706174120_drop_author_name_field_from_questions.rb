class DropAuthorNameFieldFromQuestions < ActiveRecord::Migration[6.1]
  def change
    execute "update questions set author_identifier = author_name where author_name is not null and author_identifier is null;"
    remove_column :questions, :author_name
  end
end
