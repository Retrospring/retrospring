# frozen_string_literal: true

require "rails_helper"

describe ModalController, type: :controller do
  describe "#close" do
    context "a regular web navigation request" do
      subject { get :close }

      it "should redirect to the root page" do
        subject

        expect(response).to redirect_to root_path
      end
    end

    context "a Turbo Frame request" do
      subject { get :close }

      it "renders the show_reaction template" do
        @request.headers["Turbo-Frame"] = "some_id"

        subject

        expect(response.body).to include('<turbo-frame id="modal"></turbo-frame>')
      end
    end
  end
end
