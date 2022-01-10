require 'rails_helper'

RSpec.describe Question, :type => :model do
  before :each do
    @question = Question.new(
        content: 'Is this a question?',
        user: FactoryBot.create(:user)
    )
  end

  subject { @question }

  it { should respond_to(:content) }

  it '#content returns a string' do
    expect(@question.content).to match 'Is this a question?'
  end

  it 'does not save questions longer than 512 characters' do
    @question.content = 'X' * 513
    expect{@question.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'has many answers' do
    5.times { |i| Answer.create(content: "This is an answer. #{i}", user: FactoryBot.create(:user), question: @question) }
    expect(@question.answer_count).to match 5
  end

  it 'also deletes the answers when deleted' do
    5.times { |i| Answer.create(content: "This is an answer. #{i}", user: FactoryBot.create(:user), question: @question) }
    first_answer_id = @question.answers.first.id
    @question.destroy
    expect{Answer.find(first_answer_id)}.to raise_error(ActiveRecord::RecordNotFound)
  end
end
