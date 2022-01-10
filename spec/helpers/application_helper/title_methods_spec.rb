# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper::TitleMethods, :type => :helper do
  let(:user) { FactoryBot.create(:user) }

  before do
    stub_const("APP_CONFIG", {
      'site_name' => 'Waschmaschine',
      'anonymous_name' => 'Anonymous',
      'https' => true,
      'items_per_page' => 5,
      'sharing' => {}
    })

    user.profile.display_name = 'Cool Man'
    user.profile.save!
  end

  describe "#generate_title" do
    it 'should generate a proper title' do
      expect(generate_title('Simon', 'says:', 'Nice!')).to eq('Simon says: Nice! | Waschmaschine')
    end

    it 'should only append a single quote to names that end with s' do
      expect(generate_title('Andreas', 'says:', 'Cool!', true)).to eq('Andreas\' says: Cool! | Waschmaschine')
    end

    it 'should cut content that is too long' do
      expect(generate_title('A title', 'with', 'a' * 50)).to eq('A title with aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa… | Waschmaschine')
    end
  end

  describe "#question_title" do
    let(:question) { FactoryBot.create(:question) }

    it 'should generate a proper title for the question' do
      expect(question_title(question)).to eq("Anonymous asked #{question.content} | Waschmaschine")
    end
  end

  describe "#answer_title" do
    let(:answer) { FactoryBot.create(:answer, user: user,
                                     content: 'a',
                                     question_content: 'q') }

    it 'should generate a proper title' do
      expect(answer_title(answer)).to eq('Cool Man answered q | Waschmaschine')
    end
  end

  describe "#user_title" do
    it 'should generate a proper title' do
      expect(user_title(user)).to eq("Cool Man | Waschmaschine")
    end
  end

  describe "#questions_title" do
    it 'should generate a proper title' do
      expect(questions_title(user)).to eq("Cool Man's questions | Waschmaschine")
    end
  end

  describe "#answers_title" do
    it 'should generate a proper title' do
      expect(answers_title(user)).to eq("Cool Man's answers | Waschmaschine")
    end
  end

  describe "#smiles_title" do
    it 'should generate a proper title' do
      expect(smiles_title(user)).to eq("Cool Man's smiles | Waschmaschine")
    end
  end

  describe "#comments_title" do
    it 'should generate a proper title' do
      expect(comments_title(user)).to eq("Cool Man's comments | Waschmaschine")
    end
  end

  describe "#list_title" do
    let(:list) { FactoryBot.create(:list) }

    it 'should generate a proper title' do
      expect(list_title(list)).to eq("#{list.name} | Waschmaschine")
    end
  end
end