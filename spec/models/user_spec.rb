require 'rails_helper'

RSpec.describe User, :type => :model do
  before :each do
    @user = User.new(
        screen_name: 'FunnyMeme2004',
        password: 'y_u_no_secure_password?',
        email: 'nice.meme@nsa.gov'
    )
  end

  subject { @user }

  it { should respond_to(:email) }

  it '#email returns a string' do
    expect(@user.email).to match 'nice.meme@nsa.gov'
  end

  it '#motivation_header has a default value' do
    expect(@user.motivation_header).to match ''
  end

  it 'does not save an invalid screen name' do
    @user.screen_name = '$Funny-Meme-%&2004'
    expect{@user.save!}.to raise_error(ActiveRecord::RecordInvalid)
  end
end
