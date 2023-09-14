# frozen_string_literal: true

require "rails_helper"

describe "answerbox/_smiles.html.haml", type: :view do
  subject(:rendered) do
    render partial: "answerbox/smiles", locals: { a: }
  end

  let(:a) { FactoryBot.create(:answer, user: FactoryBot.create(:user)) }

  context "no reactions" do
    it "shows an empty list" do
      expect(rendered).to match("No one smiled this yet.")
    end
  end

  context "reactions are present" do
    let!(:reactions) { FactoryBot.create_list(:smile, 5, parent: a) }

    it "shows a list of users" do
      html = Nokogiri::HTML.parse(rendered)
      selector = %(.smiles a)
      reaction_elements = html.css(selector)
      expect(reaction_elements.size).to eq(5)
    end
  end
end
