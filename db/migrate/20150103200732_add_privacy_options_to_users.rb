class AddPrivacyOptionsToUsers < ActiveRecord::Migration[4.2]
  def change
    %i{
      privacy_allow_anonymous_questions
      privacy_allow_public_timeline
      privacy_allow_stranger_answers
      privacy_show_in_search
    }.each do |sym|
      add_column :users, sym, :boolean, default: true
    end
  end
end
