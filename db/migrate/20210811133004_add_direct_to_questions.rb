# frozen_string_literal: true

class AddDirectToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :direct, :boolean, null: false, default: false

    # default all legacy questions to direct
    execute "UPDATE questions SET direct = true;"

    # All questions where
    # - the author is not 'justask' (generated questions), and
    # - the question wasn't asked anonymously
    # can be direct or not.  This depends on if the question has more than one answer
    execute "
UPDATE questions
SET direct = (NOT (questions.answer_count > 1))
WHERE author_name <> 'justask'
   OR NOT author_is_anonymous;"

    # All questions which exist in at least more than one inbox are not direct
    execute "
UPDATE questions
SET direct = false
WHERE id IN (
    SELECT question_id FROM inboxes GROUP BY question_id HAVING count(question_id) > 1
);"
  end
end
