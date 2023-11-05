# frozen_string_literal: true

require "rails_helper"

describe "answerbox/_comments.html.haml", type: :view do
  subject(:rendered) do
    render partial: "answerbox/comments", locals: {
      comments:, a:,
    }
  end

  let(:a) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }
  let(:comments) { Comment.all }

  context "no comments" do
    it "shows an empty list" do
      expect(rendered).to eq("There are no comments yet.\n")
    end
  end

  context "comments are present" do
    let!(:expected_comments) { FactoryBot.create_list(:comment, 5, answer: a, user: FactoryBot.create(:user)) }

    it "shows a list of comments" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(li.comment .comment__content)
      comment_elements = html.css(selector)
      expect(comment_elements.size).to eq(5)
      expect(comment_elements.map(&:text).map(&:strip)).to eq(expected_comments.map(&:content))
    end
  end

  context "containing your own comment" do
    let(:user) { FactoryBot.create(:user) }
    let!(:comment) { FactoryBot.create(:comment, user:, answer: a) }

    before do
      sign_in user
    end

    it "shows the delete option" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(li.comment[data-comment-id="#{comment.id}"] .btn-group a[data-action="ab-comment-destroy"])
      element = html.css(selector)
      expect(element).to_not be_nil
      expect(element.text.strip).to eq("Delete")
    end
  end

  context "containing someone else's comment" do
    let(:user) { FactoryBot.create(:user) }
    let!(:comment) { FactoryBot.create(:comment, user: FactoryBot.create(:user), answer: a) }

    before do
      sign_in user
    end

    it "does not show the delete option" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(li.comment[data-comment-id="#{comment.id}"] .btn-group a[data-action="ab-comment-destroy"])
      expect(html.css(selector)).to be_empty
    end
  end

  context "containing a comment with smiles" do
    let(:comment_author) { FactoryBot.create(:user) }
    let(:comment) { FactoryBot.create(:comment, answer: a, user: comment_author) }
    let(:other_comment) { FactoryBot.create(:comment, answer: a, user: comment_author) }

    before do
      5.times do
        user = FactoryBot.create(:user)
        user.smile comment
      end

      User.last.smile other_comment
    end

    it "shows the correct number of smiles" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(li.comment[data-comment-id="#{comment.id}"] button.smile>span)
      expect(html.css(selector).text).to eq("5")
    end
  end

  context "containing a comment you've smiled" do
    let(:user) { FactoryBot.create(:user) }
    let!(:comment) { FactoryBot.create(:comment, user: FactoryBot.create(:user), answer: a) }

    before do
      sign_in user
      user.smile comment
    end

    it "displays the comment as smiled" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(li.comment[data-comment-id="#{comment.id}"] button.unsmile)
      expect(html.css(selector)).to_not be_empty
    end
  end
end
