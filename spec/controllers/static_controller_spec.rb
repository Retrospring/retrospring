# frozen_string_literal: true

require "rails_helper"

describe StaticController, type: :controller do
  describe "#linkfilter" do
    context "called without an url" do
      subject { get :linkfilter }

      it 'should redirect to the root page' do
        subject
        expect(response).to redirect_to(root_path)
      end
    end

    context "called with an url" do
      subject { get :linkfilter, params: { url: 'https://google.com' } }

      it 'should show the passed url' do
        subject
        expect(assigns(:link)).to eq('https://google.com')
      end
    end
  end
end