# frozen_string_literal: true

class MoveSmilesToAppendables < ActiveRecord::Migration[6.1]
  def up
    execute "INSERT INTO appendables (type, user_id, parent_id, parent_type, content, created_at, updated_at)
(SELECT 'Appendable::Reaction' AS type, user_id, answer_id as parent_id, 'Answer' as parent_type, '🙂' AS content, created_at, updated_at FROM smiles)"

    execute "UPDATE notifications n
SET target_type = 'Appendable', target_id = a.id
FROM appendables a, smiles s
WHERE n.target_type = 'Smile' AND s.id = n.target_id AND a.type = 'Appendable::Reaction' AND a.parent_id = s.answer_id"

    execute "INSERT INTO appendables (type, user_id, parent_id, parent_type, content, created_at, updated_at)
(SELECT 'Appendable::Reaction' AS type, user_id, comment_id as parent_id, 'Comment' as parent_type, '🙂' AS content, created_at, updated_at FROM comment_smiles)"

    execute "UPDATE notifications n
SET target_type = 'Appendable', target_id = a.id
FROM appendables a, comment_smiles s
WHERE n.target_type = 'CommentSmile' AND s.id = n.target_id AND a.type = 'Appendable::Reaction' AND a.parent_id = s.comment_id"
  end
end
