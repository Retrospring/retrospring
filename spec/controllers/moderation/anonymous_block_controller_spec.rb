# frozen_string_literal: true

require "rails_helper"

describe Moderation::AnonymousBlockController, :ajax_controller, type: :controller do
  describe "#index" do
    subject { get :index }

    shared_examples_for "should render the page successfully" do
      it "should render the page successfully" do
        subject
        expect(response).to have_rendered(:index)
        expect(response).to have_http_status(200)
      end
    end

    shared_examples_for "empty" do
      it "should assign an empty result set" do
        subject
        expect(assigns(:anonymous_blocks)).to be_empty
      end
    end

    context "when there are no anonymous blocks" do
      include_examples "empty"
      include_examples "should render the page successfully"
    end

    context "when there are some anonymous blocks set" do
      before do
        %w[a b c].each do |identifier|
          AnonymousBlock.create!(identifier:)
        end
      end

      it "should assign an result set" do
        subject
        expect(assigns(:anonymous_blocks).length).to eq(3)
      end

      include_examples "should render the page successfully"
    end

    context "when there are only anonymous blocks assigned for users" do
      before do
        user = FactoryBot.create(:user)
        %w[a b c].each do |identifier|
          AnonymousBlock.create!(user:, identifier:)
        end
      end

      include_examples "empty"
      include_examples "should render the page successfully"
    end
  end
end
