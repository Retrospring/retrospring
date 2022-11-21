# frozen_string_literal: true

require "rails_helper"

describe AnonymousBlockController, type: :controller do
  describe "#create" do
    subject { post(:create, params:) }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      context "when all required parameters are given" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let!(:inbox) { FactoryBot.create(:inbox, user:, question:) }
        let(:params) do
          { question: question.id }
        end

        it "creates an anonymous block" do
          expect { subject }.to(change { AnonymousBlock.count }.by(1))
        end
      end

      context "when blocking a user globally" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let!(:inbox) { FactoryBot.create(:inbox, user:, question:) }
        let(:params) do
          { question: question.id, global: "true" }
        end

        context "as a moderator" do
          before do
            user.add_role(:moderator)
          end

          it "creates an site-wide anonymous block" do
            expect { subject }.to(change { AnonymousBlock.count }.by(1))
            expect(AnonymousBlock.last.user_id).to be_nil
          end
        end

        context "as a regular user" do
          it "does not create an anonymous block" do
            expect { subject }.to raise_error(Pundit::NotAuthorizedError)
          end
        end
      end
    end
  end

  describe "#destroy" do
    subject { delete(:destroy, params:) }

    context "user signed in" do
      let(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

      context "when all parameters are given" do
        let(:question) { FactoryBot.create(:question, author_identifier: "someidentifier") }
        let(:block) { AnonymousBlock.create(user:, identifier: "someidentifier", question:) }
        let(:params) do
          { id: block.id }
        end

        it "destroys the anonymous block" do
          subject

          expect(AnonymousBlock.exists?(block.id)).to eq(false)
        end
      end
    end
  end
end
