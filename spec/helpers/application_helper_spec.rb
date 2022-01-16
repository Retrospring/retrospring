# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "#inbox_count" do
    context "no signed in user" do
      it "should return 0 as inbox count" do
        expect(helper.inbox_count).to eq(0)
      end
    end

    context "user is signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:question) { FactoryBot.create(:question) }

      before do
        sign_in(user)
        Inbox.create(user_id: user.id, question_id: question.id, new: true)
      end

      it "should return the inbox count" do
        expect(helper.inbox_count).to eq(1)
      end
    end
  end

  describe "#notification_count" do
    context "no signed in user" do
      it "should return 0 as notification count" do
        expect(helper.notification_count).to eq(0)
      end
    end

    context "user is signed in" do
      let(:user) { FactoryBot.create(:user) }
      let(:another_user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
        another_user.follow(user)
      end

      it "should return the notification count" do
        expect(helper.notification_count).to eq(1)
      end
    end
  end

  describe "#privileged" do
    context "current user and checked user do not match" do
      let(:user) { FactoryBot.create(:user) }
      let(:priv_user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      it "should not return true" do
        expect(helper.privileged?(priv_user)).to eq(false)
      end
    end

    context "current user and checked user match" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      it "should return true" do
        expect(helper.privileged?(user)).to eq(true)
      end
    end

    context "current user is moderator" do
      let(:user) { FactoryBot.create(:user, roles: [:moderator]) }
      let(:priv_user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      it "should return true" do
        expect(helper.privileged?(priv_user)).to eq(true)
      end
    end
  end

  describe "#ios_web_app" do
    context "Non-iOS device" do
      it "should not return true" do
        controller.request.user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2;"

        expect(helper.ios_web_app?).to eq(false)
      end
    end

    context "iOS device (not in web app mode)" do
      it "should not return true" do
        controller.request.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Version/8.0 Mobile/12B435 Safari/600.1.4"

        expect(helper.ios_web_app?).to eq(false)
      end
    end

    context "iOS device" do
      it "should return true" do
        controller.request.user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 8_1_1 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12B435"

        expect(helper.ios_web_app?).to eq(true)
      end
    end
  end

  describe "#rails_admin_path_for_resource" do
    context "user resource" do
      let(:resource) { FactoryBot.create(:user) }
      subject { rails_admin_path_for_resource(resource) }

      it "should return a URL to the given resource within rails admin" do
        expect(subject).to eq("/justask_admin/user/#{resource.id}")
      end
    end
  end
end
