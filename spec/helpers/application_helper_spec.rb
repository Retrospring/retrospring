# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, :type => :helper do
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