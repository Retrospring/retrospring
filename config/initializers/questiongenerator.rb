# frozen_string_literal: true

Rails.application.config.to_prepare do
  QuestionGenerator.question_base_path = File.expand_path("../questions", __dir__)
  QuestionGenerator.compile
end
