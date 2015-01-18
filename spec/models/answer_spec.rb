require 'rails_helper'

RSpec.describe Answer, :type => :model do
  before :each do
    @answer = Answer.new(
        content: 'This is an answer.',
        user: FactoryGirl.create(:user),
        question: FactoryGirl.create(:question)
    )
  end

  subject { @answer }

  it { should respond_to(:content) }

  it '#content returns a string' do
    expect(@answer.content).to match 'This is an answer.'
  end
end
