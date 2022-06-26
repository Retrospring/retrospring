# frozen_string_literal: true

require "rails_helper"

describe Settings::ThemeController, type: :controller do
  describe "#edit" do
    subject { get :edit }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "renders the edit template" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "#update" do
    let(:user) { FactoryBot.create(:user) }

    let(:update_attributes) do
      {
        theme: {
          primary_color:     6174129,
          primary_text:      16777215,
          danger_color:      14431557,
          danger_text:       16777215,
          success_color:     2664261,
          success_text:      16777215,
          warning_color:     16761095,
          warning_text:      2697513,
          info_color:        1548984,
          info_text:         16777215,
          dark_color:        3422784,
          dark_text:         15658734,
          light_color:       16316922,
          light_text:        0,
          raised_background: 16777215,
          raised_accent:     16250871,
          background_color:  15789556,
          body_text:         0,
          muted_text:        7107965,
          input_color:       15789556,
          input_text:        0
        }
      }
    end

    subject { patch :update, params: update_attributes }

    context "user signed in" do
      before { sign_in user }

      context "user has no theme" do
        it "creates a new theme" do
          expect { subject }.to(change { user.reload.theme })
        end

        it "renders the edit template" do
          subject
          expect(response).to redirect_to(:settings_theme)
        end
      end

      context "user has a theme" do
        let(:user) { FactoryBot.create(:user) }
        let(:theme) { FactoryBot.create(:theme, user: user) }

        it "updates the theme" do
          expect { subject }.to(change { theme.reload.attributes })
        end

        it "renders the edit template" do
          subject
          expect(response).to redirect_to(:settings_theme)
        end
      end
    end
  end
end
