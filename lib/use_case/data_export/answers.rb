# frozen_string_literal: true

module UseCase
  module DataExport
    class Answers < UseCase::DataExport::Base
      def files = {
        "answers.json" => json_file!(
          answers: user.answers.map(&method(:collect_answer)),
        ),
      }

      def collect_answer(answer)
        {}.tap do |h|
          column_names(::Answer).each do |field|
            h[field] = answer[field]
            h[:related] = related_fields(answer)
          end
        end
      end

      def related_fields(answer) = {
        question: question_for(answer),
        comments: comments_for(answer),
      }

      def question_for(answer)
        return unless answer.question

        question = answer.question
        {}.tap do |q|
          q.merge!(
            id:         nil,
            anonymous:  false,
            generated:  false,
            direct:     false,
            author:     nil,
            content:    nil,
            created_at: nil,
          )

          %i[id direct content created_at].each do |field|
            q[field] = question[field]
          end

          if question.generated?
            q[:generated] = true
            q[:anonymous] = true
          elsif question.author_is_anonymous
            q[:anonymous] = true
          else
            q[:author] = lean_user(question.user)
          end
        end
      end

      def comments_for(answer) = [].tap do |c|
        next if answer.comments.empty?

        answer.comments.order(:created_at).each do |comment|
          c << {
            id:          comment.id,
            author:      lean_user(comment.user),
            smile_count: comment.smile_count,
            content:     comment.content,
            created_at:  comment.created_at,
          }
        end
      end

      def lean_user(user)
        return unless user

        {
          id:          user.id,
          screen_name: user.screen_name,
        }
      end
    end
  end
end
