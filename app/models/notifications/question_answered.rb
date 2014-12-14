class Notifications::QuestionAnswered < Notification
  def linked_object
    Answer.where(id: self.target_id).first
  end
end