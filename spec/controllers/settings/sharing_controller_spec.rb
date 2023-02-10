# frozen_string_literal: true

require "rails_helper"

describe Settings::SharingController, type: :controller do
  describe "#edit" do
    subject { get :edit }

    it "redirects to the sign in page when not signed in" do
      expect(subject).to redirect_to new_user_session_path
    end

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in user }

      it "renders the edit template" do
        expect(subject).to render_template(:edit)
      end
    end
  end

  describe "#update" do
    subject { patch :update, params: { user: user_params } }
    let(:user_params) do
      {
        sharing_enabled:    "1",
        sharing_autoclose:  "1",
        sharing_custom_url: "",
      }
    end

    it "redirects to the sign in page when not signed in" do
      expect(subject).to redirect_to new_user_session_path
    end

    context "user signed in" do
      let(:user) { FactoryBot.create :user }

      before { sign_in user }

      it "renders the edit template" do
        expect(subject).to render_template(:edit)
      end

      it "updates the user's sharing preferences" do
        expect { subject }
          .to change { user.reload.slice(:sharing_enabled, :sharing_autoclose, :sharing_custom_url).values }
          .from([false, false, nil])
          .to([true, true, ""])
      end

      it "sets the success flash" do
        subject
        expect(flash[:success]).to eq(I18n.t("settings.sharing.update.success"))
      end

      context "when passed a valid url" do
        let(:user_params) do
          super().merge(
            sharing_custom_url: "https://example.com/share?text="
          )
        end

        it "renders the edit template" do
          expect(subject).to render_template(:edit)
        end

        it "updates the user's sharing preferences" do
          expect { subject }
            .to change { user.reload.slice(:sharing_enabled, :sharing_autoclose, :sharing_custom_url).values }
            .from([false, false, nil])
            .to([true, true, "https://example.com/share?text="])
        end

        it "sets the success flash" do
          subject
          expect(flash[:success]).to eq(I18n.t("settings.sharing.update.success"))
        end
      end

      context "when passed an invalid url" do
        let(:user_params) do
          super().merge(
            sharing_custom_url: "nfs://example.com/data"
          )
        end

        it "renders the edit template" do
          expect(subject).to render_template(:edit)
        end

        it "updates the user's sharing preferences" do
          expect { subject }
            .not_to(change { user.reload.slice(:sharing_enabled, :sharing_autoclose, :sharing_custom_url).values })
        end

        it "sets the error flash" do
          subject
          expect(flash[:error]).to eq(I18n.t("settings.sharing.update.error"))
        end
      end

      context "when unticking boolean settings" do
        let(:user_params) do
          super().merge(
            sharing_enabled:   "0",
            sharing_autoclose: "0"
          )
        end

        let(:user) { FactoryBot.create :user, sharing_enabled: true, sharing_autoclose: true, sharing_custom_url: "https://example.com/share?text=" }

        it "renders the edit template" do
          expect(subject).to render_template(:edit)
        end

        it "updates the user's sharing preferences" do
          expect { subject }
            .to change { user.reload.slice(:sharing_enabled, :sharing_autoclose, :sharing_custom_url).values }
            .from([true, true, "https://example.com/share?text="])
            .to([false, false, ""])
        end

        it "sets the success flash" do
          subject
          expect(flash[:success]).to eq(I18n.t("settings.sharing.update.success"))
        end
      end
    end
  end
end
