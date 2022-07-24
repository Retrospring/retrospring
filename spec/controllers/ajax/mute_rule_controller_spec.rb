require 'rails_helper'

describe Ajax::MuteRuleController, :ajax_controller, type: :controller do

  describe "#create" do
    subject { post(:create, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      let(:params) { { muted_phrase: 'test' } }
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "id" => MuteRule.last.id,
          "message" => "Rule added successfully.",
        }
      end

      it "creates a mute rule" do
        expect { subject }.to change { MuteRule.count }.by(1)
        expect(response).to have_http_status(:success)

        rule = MuteRule.first
        expect(rule.user_id).to eq(user.id)
        expect(rule.muted_phrase).to eq('test')
      end

      include_examples "returns the expected response"
    end
  end

  describe "#destroy" do
    subject { delete(:destroy, params: params) }

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      let(:rule) { MuteRule.create(user: user, muted_phrase: 'test') }
      let(:params) { { id: rule.id } }
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => "Rule deleted successfully."
        }
      end

      it "deletes a mute rule" do
        subject
        expect(response).to have_http_status(:success)

        expect(MuteRule.exists?(rule.id)).to eq(false)

      end

      include_examples "returns the expected response"
    end
  end

end
