# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let!(:me) { FactoryBot.create :user }

  describe "basic assigns" do
    before :each do
      @user = User.new(
        screen_name: "FunnyMeme2004",
        password:    "y_u_no_secure_password?",
        email:       "nice.meme@nsa.gov"
      )
      Profile.new(user: @user)
    end

    subject { @user }

    it { should respond_to(:email) }

    it "#email returns a string" do
      expect(@user.email).to match "nice.meme@nsa.gov"
    end

    it "#motivation_header has a default value" do
      expect(@user.profile.motivation_header).to match ""
    end

    it "does not save an invalid screen name" do
      @user.screen_name = "$Funny-Meme-%&2004"
      expect { @user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe "email validation" do
    subject do
      FactoryBot.build(:user, email: email).tap(&:validate).errors[:email]
    end

    shared_examples_for "valid email" do |example_email|
      context "when email is #{example_email}" do
        let(:email) { example_email }

        it "does not have validation errors" do
          expect(subject).to be_empty
        end
      end
    end

    shared_examples_for "invalid email" do |example_email|
      context "when email is #{example_email}" do
        let(:email) { example_email }

        it "has validation errors" do
          expect(subject).not_to be_empty
        end
      end
    end

    include_examples "valid email", "ifyouusethismailyouarebanned@nilsding.org"
    include_examples "valid email", "fritz.fantom@gmail.com"
    include_examples "valid email", "fritz.fantom@columbiamail.co"
    include_examples "valid email", "fritz.fantom@protonmail.com"
    include_examples "valid email", "fritz.fantom@example.email"
    include_examples "valid email", "fritz.fantom@enterprise.k8s.420stripes.k8s.needs.more.k8s.jira.atlassian.k8s.eu-central-1.s3.amazonaws.com"
    include_examples "invalid email", "@jack"

    # examples from the real world:

    # .con is not a valid TLD
    include_examples "invalid email", "fritz.fantom@gmail.con"
    include_examples "invalid email", "fritz.fantom@protonmail.con"
    # neither is .coom
    include_examples "invalid email", "fritz.fantom@gmail.coom"
    # nor .cmo
    include_examples "invalid email", "gustav.geldsack@gmail.cmo"
    # nor .mail (.email is, however)
    include_examples "invalid email", "fritz.fantom@proton.mail"
    # common typos:
    include_examples "invalid email", "fritz.fantom@fmail.com"
    include_examples "invalid email", "fritz.fantom@gamil.com"
    include_examples "invalid email", "fritz.fantom@gemail.com"
    include_examples "invalid email", "fritz.fantom@gmail.cm"
    include_examples "invalid email", "fritz.fantom@gmail.co"
    include_examples "invalid email", "fritz.fantom@gmailcom"
    include_examples "invalid email", "fritz.fantom@gmaile.com"
    include_examples "invalid email", "fritz.fantom@gmaill.com"
    include_examples "invalid email", "fritz.fantom@gmali.com"
    include_examples "invalid email", "fritz.fantom@hotamil.com"
    include_examples "invalid email", "fritz.fantom@hotmailcom"
    include_examples "invalid email", "fritz.fantom@hotmaill.com"
    include_examples "invalid email", "fritz.fantom@iclooud.com"
    include_examples "invalid email", "fritz.fantom@iclould.com"
    include_examples "invalid email", "fritz.fantom@icluod.com"
    # gail.com would be a valid email address, but enough people typo it
    #
    # if you're the owner of that TLD and would like to use your email on
    # retrospring, feel free to open a PR that removes this ;-)
    include_examples "invalid email", "fritz.fantom@gail.com"
    # no TLD
    include_examples "invalid email", "fritz.fantom@gmail"
    include_examples "invalid email", "fritz.fantom@protonmail"
  end

  # -- User::TimelineMethods --

  shared_examples_for "result is blank" do
    it "result is blank" do
      expect(subject).to be_blank
    end
  end

  describe "#timeline" do
    subject { me.timeline }

    context "user answered nothing and is not following anyone" do
      include_examples "result is blank"
    end

    context "user answered something and is not following anyone" do
      let(:answer) { FactoryBot.create(:answer, user: me) }

      let(:expected) { [answer] }

      it "includes the answer" do
        expect(subject).to eq(expected)
      end
    end

    context "user answered something and follows users with answers" do
      let(:user1) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user) }
      let(:answer1) { FactoryBot.create(:answer, user: user1, created_at: 12.hours.ago) }
      let(:answer2) { FactoryBot.create(:answer, user: me, created_at: 1.day.ago) }
      let(:answer3) { FactoryBot.create(:answer, user: user2, created_at: 10.minutes.ago) }
      let(:answer4) { FactoryBot.create(:answer, user: user1, created_at: Time.now.utc) }

      let!(:expected) do
        [answer4, answer3, answer1, answer2]
      end

      before(:each) do
        me.follow(user1)
        me.follow(user2)
      end

      it "includes all answers" do
        expect(subject).to include(answer1)
        expect(subject).to include(answer2)
        expect(subject).to include(answer3)
        expect(subject).to include(answer4)
      end

      it "result is ordered by created_at in reverse order" do
        expect(subject).to eq(expected)
      end
    end
  end

  describe "#cursored_timeline" do
    let(:last_id) { nil }

    subject { me.cursored_timeline(last_id: last_id, size: 3) }

    context "user answered nothing and is not following anyone" do
      include_examples "result is blank"
    end

    context "user answered something and is not following anyone" do
      let(:answer) { FactoryBot.create(:answer, user: me) }

      let(:expected) { [answer] }

      it "includes the answer" do
        expect(subject).to eq(expected)
      end
    end

    context "user answered something and follows users with answers" do
      let(:user1) { FactoryBot.create(:user) }
      let(:user2) { FactoryBot.create(:user) }
      let!(:answer1) { FactoryBot.create(:answer, user: me, created_at: 1.day.ago) }
      let!(:answer2) { FactoryBot.create(:answer, user: user1, created_at: 12.hours.ago) }
      let!(:answer3) { FactoryBot.create(:answer, user: user2, created_at: 10.minutes.ago) }
      let!(:answer4) { FactoryBot.create(:answer, user: user1, created_at: Time.now.utc) }

      before(:each) do
        me.follow(user1)
        me.follow(user2)
      end

      context "last_id is nil" do
        let(:last_id) { nil }
        let(:expected) do
          [answer4, answer3, answer2]
        end

        it "includes three answers" do
          expect(subject).not_to include(answer1)
          expect(subject).to include(answer2)
          expect(subject).to include(answer3)
          expect(subject).to include(answer4)
        end

        it "result is ordered by created_at in reverse order" do
          expect(subject).to eq(expected)
        end
      end

      context "last_id is answer2.id" do
        let(:last_id) { answer2.id }

        it "includes answer1" do
          expect(subject).to include(answer1)
          expect(subject).not_to include(answer2)
          expect(subject).not_to include(answer3)
          expect(subject).not_to include(answer4)
        end
      end

      context "last_id is answer1.id" do
        let(:last_id) { answer1.id }

        include_examples "result is blank"
      end
    end
  end
end
