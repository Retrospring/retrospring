class MoveSmilesToAppendables < ActiveRecord::Migration[6.1]
  def up_only
    execute "INSERT INTO appendables (type, user_id, parent_id, parent_type, content, created_at, updated_at)
(SELECT 'Appendable::Reaction' AS type, user_id, answer_id as parent_id, 'Answer' as parent_type, '🙂' AS content, created_at, updated_at FROM smiles)"
  end
end
