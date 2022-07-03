# frozen_string_literal: true

require "rails_helper"

describe Settings::BlocksController, type: :controller do
  let(:user) { FactoryBot.create(:user) }

  describe "#index" do
    subject { get :index }

    context "user signed in" do
      before(:each) { sign_in user }

      it "shows the edit_blocks page" do
        subject
        expect(response).to have_rendered(:index)
      end

      it "only contains blocks of the signed in user" do
        other_user = create(:user)
        other_user.block(user)

        subject

        expect(assigns(:blocks)).to eq(user.active_block_relationships)
      end

      it "only contains anonymous blocks of the signed in user" do
        other_user = create(:user)
        question = create(:question)
        other_user.anonymous_blocks.create(identifier: "very-real-identifier", question_id: question.id)

        subject

        expect(assigns(:anonymous_blocks)).to eq(user.anonymous_blocks)
      end
    end
  end
end
