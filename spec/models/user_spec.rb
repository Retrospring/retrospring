# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  let!(:me) { FactoryBot.create :user }

  describe "basic assigns" do
    before :each do
      @user = User.new(
        screen_name: "FunnyMeme2004",
        password:    "y_u_no_secure_password?",
        email:       "nice.meme@nsa.gov",
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

  describe "callbacks" do
    describe "after_destroy" do
      it "increments the users_destroyed metric" do
        expect { me.destroy }.to change { Retrospring::Metrics::USERS_DESTROYED.values.values.sum }.by(1)
      end
    end

    describe "after_create" do
      subject :user do
        User.create!(
          screen_name: "konqi",
          email:       "konqi@example.rrerr.net",
          password:    "dragonsRQt5",
        )
      end

      it "creates a profile for the user" do
        expect { user }.to change { Profile.count }.by(1)
        expect(Profile.find_by(user:).user).to eq(user)
      end

      it "increments the users_created metric" do
        expect { user }.to change { Retrospring::Metrics::USERS_CREATED.values.values.sum }.by(1)
      end
    end
  end

  describe "custom sharing url validation" do
    subject do
      FactoryBot.build(:user, sharing_custom_url: url).tap(&:validate).errors[:sharing_custom_url]
    end

    shared_examples_for "valid url" do |example_url|
      context "when url is #{example_url}" do
        let(:url) { example_url }

        it "does not have validation errors" do
          expect(subject).to be_empty
        end
      end
    end

    shared_examples_for "invalid url" do |example_url|
      context "when url is #{example_url}" do
        let(:url) { example_url }

        it "has validation errors" do
          expect(subject).not_to be_empty
        end
      end
    end

    include_examples "valid url", "https://myfunnywebsite.com/"
    include_examples "valid url", "https://desu.social/share?text="
    include_examples "valid url", "http://insecurebutvalid.business/"
    include_examples "invalid url", "ftp://fileprotocols.cool/"
    include_examples "invalid url", "notevenanurl"
    include_examples "invalid url", %(https://richtig <strong>oarger</strong> shice) # passes the regexp, but trips up URI.parse
    include_examples "invalid url", %(https://österreich.gv.at) # needs to be ASCII
  end

  describe "email validation" do
    subject do
      FactoryBot.build(:user, email:).tap(&:validate).errors[:email]
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
    include_examples "valid email", "fritz.fantom@emacs.horse"
    include_examples "invalid email", "@jack"

    # examples from the real world:

    # .carrd is not a valid TLD
    include_examples "invalid email", "fritz.fantom@gmail.carrd"
    # neither is .con
    include_examples "invalid email", "fritz.fantom@gmail.con"
    include_examples "invalid email", "fritz.fantom@protonmail.con"
    # nor .coom
    include_examples "invalid email", "fritz.fantom@gmail.coom"
    # nor .cmo
    include_examples "invalid email", "gustav.geldsack@gmail.cmo"
    # nor .mail (.email is, however)
    include_examples "invalid email", "fritz.fantom@proton.mail"
    # common typos:
    include_examples "invalid email", "fritz.fantom@aoo.com"
    include_examples "invalid email", "fritz.fantom@fmail.com"
    include_examples "invalid email", "fritz.fantom@gamil.com"
    include_examples "invalid email", "fritz.fantom@gemail.com"
    include_examples "invalid email", "fritz.fantom@gmaik.com"
    include_examples "invalid email", "fritz.fantom@gmail.cm"
    include_examples "invalid email", "fritz.fantom@gmail.co"
    include_examples "invalid email", "fritz.fantom@gmail.co.uk"
    include_examples "invalid email", "fritz.fantom@gmail.om"
    include_examples "invalid email", "fritz.fantom@gmailcom"
    include_examples "invalid email", "fritz.fantom@gmaile.com"
    include_examples "invalid email", "fritz.fantom@gmaill.com"
    include_examples "invalid email", "fritz.fantom@gmali.com"
    include_examples "invalid email", "fritz.fantom@gmaul.com"
    include_examples "invalid email", "fritz.fantom@gnail.com"
    include_examples "invalid email", "fritz.fantom@hornail.com"
    include_examples "invalid email", "fritz.fantom@hotamil.com"
    include_examples "invalid email", "fritz.fantom@hotmai.com"
    include_examples "invalid email", "fritz.fantom@hotmailcom"
    include_examples "invalid email", "fritz.fantom@hotmaill.com"
    include_examples "invalid email", "fritz.fantom@iclooud.com"
    include_examples "invalid email", "fritz.fantom@iclould.com"
    include_examples "invalid email", "fritz.fantom@icluod.com"
    include_examples "invalid email", "fritz.fantom@maibox.org"
    include_examples "invalid email", "fritz.fantom@protonail.com"
    include_examples "invalid email", "fritz.fantom@xn--gmail-xk1c.com"
    include_examples "invalid email", "fritz.fantom@yahooo.com"
    include_examples "invalid email", "fritz.fantom@☺gmail.com"
    # gail.com would be a valid email address, but enough people typo it
    #
    # if you're the owner of that TLD and would like to use your email on
    # retrospring, feel free to open a PR that removes this ;-)
    include_examples "invalid email", "fritz.fantom@gail.com"
    # no TLD
    include_examples "invalid email", "fritz.fantom@gmail"
    include_examples "invalid email", "fritz.fantom@protonmail"
  end

  describe "#to_param" do
    subject { me.to_param }

    it { is_expected.to eq me.screen_name }
  end
end
