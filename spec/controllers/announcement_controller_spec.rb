# frozen_string_literal: true

require "rails_helper"

describe AnnouncementController, type: :controller do
  let(:user) { FactoryBot.create(:user, roles: [:administrator]) }

  describe "#index" do
    subject { get :index }

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "renders the index template" do
        subject
        expect(response).to render_template(:index)
      end

      context "no announcements" do
        it "@announcements is empty" do
          subject
          expect(assigns(:announcements)).to be_blank
        end
      end

      context "one announcement" do
        let!(:announcement) { Announcement.create(content: "I am announcement", user: user, starts_at: Time.current, ends_at: 2.days.from_now) }

        it "includes the announcement in the @announcements assign" do
          subject
          expect(assigns(:announcements)).to include(announcement)
        end
      end
    end
  end

  describe "#new" do
    subject { get :new }

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "renders the new template" do
        subject
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#create" do
    let :announcement_params do
      {
        announcement: {
          content:   "I like dogs!",
          starts_at: Time.current,
          ends_at:   2.days.from_now
        }
      }
    end

    subject { post :create, params: announcement_params }

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "creates an announcement" do
        expect { subject }.to change { Announcement.count }.by(1)
      end

      it "redirects to announcement#index" do
        subject
        expect(response).to redirect_to(:announcement_index)
      end
    end

    context "submitting a malformed announcement" do
      before(:each) { sign_in(user) }

      let :announcement_params do
        {
          announcement: {
            content:   "I like dogs!",
            starts_at: Time.current,
            ends_at:   2.days.ago
          }
        }
      end

      it "stays in the new view when a malformed announcement is submitted" do
        post :create, params: announcement_params
        expect(response).to render_template(:new)
      end
    end
  end

  describe "#edit" do
    let! :announcement do
      Announcement.create(content:   "Dogs are pretty cool, I guess",
                          starts_at: 3.days.from_now,
                          ends_at:   10.days.from_now,
                          user:      user)
    end

    subject { get :edit, params: { id: announcement.id } }

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "renders the edit template" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "#update" do
    let :announcement_params do
      {
        content: "The trebuchet is the superior siege weapon"
      }
    end

    let! :announcement do
      Announcement.create(content:   "Dogs are pretty cool, I guess",
                          starts_at: 3.days.from_now,
                          ends_at:   10.days.from_now,
                          user:      user)
    end

    subject do
      patch :update, params: {
        id:           announcement.id,
        announcement: announcement_params
      }
    end

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "updates the announcement" do
        subject
        updated = Announcement.find announcement.id
        expect(updated.content).to eq(announcement_params[:content])
      end

      it "redirects to announcement#index" do
        subject
        expect(response).to redirect_to(:announcement_index)
      end
    end

    context "submitting a malformed announcement" do
      before(:each) { sign_in(user) }

      let :announcement_params do
        {
          content:   "I like dogs!",
          starts_at: Time.current,
          ends_at:   2.days.ago
        }
      end

      subject do
        patch :update, params: {
          id:           announcement.id,
          announcement: announcement_params
        }
      end

      it "stays in the edit view when a malformed announcement is submitted" do
        subject
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "#destroy" do
    let! :announcement do
      Announcement.create(content:   "Dogs are pretty cool, I guess",
                          starts_at: 3.days.from_now,
                          ends_at:   10.days.from_now,
                          user:      user)
    end

    subject { delete :destroy, params: { id: announcement.id } }

    context "user signed in" do
      before(:each) { sign_in(user) }

      it "deletes the announcement" do
        expect { subject }.to change { Announcement.count }.by(-1)
      end

      it "redirects to announcement#index" do
        subject
        expect(response).to redirect_to(:announcement_index)
      end
    end
  end
end
