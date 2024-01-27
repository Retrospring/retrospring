# frozen_string_literal: true

require "rails_helper"

describe InboxController, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  let(:original_inbox_updated_at) { 1.day.ago }
  let(:user) { FactoryBot.create(:user, inbox_updated_at: original_inbox_updated_at) }

  describe "#show" do
    shared_examples_for "sets the expected ivars" do
      let(:expected_assigns) { {} }

      it "sets the expected ivars" do
        subject

        expected_assigns.each do |name, value|
          expect(assigns[name]).to eq(value)
        end
      end
    end

    subject { get :show }

    it "redirects to the login page when not signed in" do
      expect(subject).to redirect_to(new_user_session_path)
    end

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      it "renders the correct template" do
        subject
        expect(response).to render_template("show")
      end

      context "when inbox is empty" do
        include_examples "sets the expected ivars",
                         inbox:               [],
                         inbox_last_id:       nil,
                         more_data_available: false,
                         inbox_count:         0,
                         delete_id:           "ib-delete-all",
                         disabled:            true
      end

      context "when inbox has an amount of questions less than page size" do
        let!(:inbox_entry) { InboxEntry.create(user:, new: true, question: FactoryBot.create(:question)) }

        include_examples "sets the expected ivars" do
          let(:expected_assigns) do
            {
              inbox:               [inbox_entry],
              inbox_last_id:       inbox_entry.id,
              more_data_available: false,
              inbox_count:         1,
              delete_id:           "ib-delete-all",
              disabled:            nil,
            }
          end
        end

        it "updates the inbox entry status" do
          expect { subject }.to change { inbox_entry.reload.new? }.from(true).to(false)
        end

        include_examples "touches user timestamp", :inbox_updated_at

        context "when requested the turbo stream format" do
          subject { get :show, format: :turbo_stream }

          it "updates the inbox entry status" do
            expect { subject }.to change { inbox_entry.reload.new? }.from(true).to(false)
          end
        end
      end

      context "when inbox has an amount of questions more than page size" do
        let(:inbox_entry_fillers_page1) do
          # 9 times => 1 entry less than default page size
          9.times.map { InboxEntry.create(user:, question: FactoryBot.create(:question)) }
        end
        let(:last_inbox_entry_page1) { InboxEntry.create(user:, question: FactoryBot.create(:question)) }
        let(:inbox_entry_fillers_page2) do
          5.times.map { InboxEntry.create(user:, question: FactoryBot.create(:question)) }
        end
        let(:last_inbox_entry_page2) { InboxEntry.create(user:, question: FactoryBot.create(:question)) }

        before do
          # create inbox entries in reverse so pagination works as expected
          last_inbox_entry_page2
          inbox_entry_fillers_page2
          last_inbox_entry_page1
          inbox_entry_fillers_page1
        end

        include_examples "sets the expected ivars" do
          let(:expected_assigns) do
            {
              inbox:               [*inbox_entry_fillers_page1.reverse, last_inbox_entry_page1],
              inbox_last_id:       last_inbox_entry_page1.id,
              more_data_available: true,
              inbox_count:         16,
              delete_id:           "ib-delete-all",
              disabled:            nil,
            }
          end
        end

        context "when passed the last_id param" do
          subject { get :show, params: { last_id: last_inbox_entry_page1.id } }

          include_examples "sets the expected ivars" do
            let(:expected_assigns) do
              {
                inbox:               [*inbox_entry_fillers_page2.reverse, last_inbox_entry_page2],
                inbox_last_id:       last_inbox_entry_page2.id,
                more_data_available: false,
                inbox_count:         16,
                delete_id:           "ib-delete-all",
                disabled:            nil,
              }
            end
          end
        end
      end

      context "when passed the author param" do
        let!(:other_user) { FactoryBot.create(:user) }
        let!(:unrelated_user) { FactoryBot.create(:user) }

        let!(:generic_inbox_entry1) do
          InboxEntry.create(
            user:,
            question: FactoryBot.create(
              :question,
              user:                unrelated_user,
              author_is_anonymous: false,
            ),
          )
        end
        let!(:generic_inbox_entry2) { InboxEntry.create(user:, question: FactoryBot.create(:question)) }

        subject { get :show, params: { author: author_param } }

        context "with an existing screen name" do
          let(:author_param) { other_user.screen_name }

          context "with no questions from the other user in the inbox" do
            include_examples "sets the expected ivars" do
              # these are the ivars set before the redirect happened
              let(:expected_assigns) do
                {
                  inbox:               [],
                  inbox_last_id:       nil,
                  more_data_available: false,
                  inbox_count:         0,
                }
              end
            end
          end

          context "with no non-anonymous questions from the other user in the inbox" do
            let!(:anonymous_inbox_entry) do
              InboxEntry.create(
                user:,
                question: FactoryBot.create(
                  :question,
                  user:                other_user,
                  author_is_anonymous: true,
                ),
              )
            end

            include_examples "sets the expected ivars" do
              # these are the ivars set before the redirect happened
              let(:expected_assigns) do
                {
                  inbox:               [],
                  inbox_last_id:       nil,
                  more_data_available: false,
                  inbox_count:         0,
                }
              end
            end
          end

          context "with both non-anonymous and anonymous questions from the other user in the inbox" do
            let!(:non_anonymous_inbox_entry) do
              InboxEntry.create(
                user:,
                question: FactoryBot.create(
                  :question,
                  user:                other_user,
                  author_is_anonymous: false,
                ),
              )
            end
            let!(:anonymous_inbox_entry) do
              InboxEntry.create(
                user:,
                question: FactoryBot.create(
                  :question,
                  user:                other_user,
                  author_is_anonymous: true,
                ),
              )
            end

            include_examples "sets the expected ivars" do
              let(:expected_assigns) do
                {
                  inbox:               [non_anonymous_inbox_entry],
                  inbox_last_id:       non_anonymous_inbox_entry.id,
                  more_data_available: false,
                  inbox_count:         1,
                  delete_id:           "ib-delete-all-author",
                  disabled:            nil,
                }
              end
            end
          end
        end
      end

      context "when passed the anonymous param" do
        let!(:other_user) { FactoryBot.create(:user) }
        let!(:generic_inbox_entry) do
          InboxEntry.create(
            user:,
            question: FactoryBot.create(
              :question,
              user:                other_user,
              author_is_anonymous: false,
            ),
          )
        end

        let!(:inbox_entry_fillers) do
          # 9 times => 1 entry less than default page size
          9.times.map { InboxEntry.create(user:, question: FactoryBot.create(:question, author_is_anonymous: true)) }
        end

        subject { get :show, params: { anonymous: true } }

        include_examples "sets the expected ivars" do
          let(:expected_assigns) do
            {
              inbox:               [*inbox_entry_fillers.reverse],
              more_data_available: false,
              inbox_count:         9,
            }
          end
        end
      end

      context "when passed the anonymous and the author param" do
        let!(:other_user) { FactoryBot.create(:user) }
        let!(:generic_inbox_entry) do
          InboxEntry.create(
            user:,
            question: FactoryBot.create(
              :question,
              user:                other_user,
              author_is_anonymous: false,
            ),
          )
        end

        let!(:inbox_entry_fillers) do
          # 9 times => 1 entry less than default page size
          9.times.map { InboxEntry.create(user:, question: FactoryBot.create(:question, author_is_anonymous: true)) }
        end

        subject { get :show, params: { anonymous: true, author: "some_name" } }

        include_examples "sets the expected ivars" do
          let(:expected_assigns) do
            {
              inbox:               [],
              more_data_available: false,
              inbox_count:         0,
            }
          end
        end
      end
    end
  end

  describe "#create" do
    subject { post :create }

    it "redirects to the login page when not signed in" do
      expect(subject).to redirect_to(new_user_session_path)
    end

    context "when user is signed in" do
      before(:each) { sign_in(user) }

      it "creates an inbox entry" do
        expect { subject }.to(change { user.inbox_entries.count }.by(1))
      end

      include_examples "touches user timestamp", :inbox_updated_at
    end
  end
end
