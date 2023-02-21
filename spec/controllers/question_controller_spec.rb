# frozen_string_literal: true

require "rails_helper"

describe QuestionController, type: :controller do
  describe "#show" do
    subject { get :show, params: { id: question.id, username: question.user.screen_name } }

    before do
      stub_const("APP_CONFIG", {
                   "site_name"      => "Specspring",
                   "hostname"       => "test.host",
                   "https"          => false,
                   "items_per_page" => 10,
                 })
    end

    context "question exists" do
      let(:question) { FactoryBot.create(:question, user: FactoryBot.create(:user)) }

      context "no answers" do
        it "renders an empty list" do
          expect(subject).to have_http_status(:ok)
          expect(assigns(:question)).to eq(question)
          expect(assigns(:answers)).to be_empty
          expect(assigns(:answers_last_id)).to be_nil
          expect(assigns(:more_data_available)).to eq(false)
        end
      end

      context "some answers" do
        before do
          num_answers.times do
            FactoryBot.create(:answer, question:, user: FactoryBot.create(:user))
          end
        end

        let(:num_answers) { 10 }

        it "renders a list of questions" do
          expect(subject).to have_http_status(:ok)
          expect(assigns(:question)).to eq(question)
          expect(assigns(:answers).length).to eq(10)
          expect(assigns(:answers_last_id)).to_not be_nil
          expect(assigns(:more_data_available)).to eq(false)
        end

        context "enough answers to paginate" do
          let(:num_answers) { 11 }

          it "renders a list of questions" do
            expect(subject).to have_http_status(:ok)
            expect(assigns(:question)).to eq(question)
            expect(assigns(:answers).length).to eq(10)
            expect(assigns(:answers_last_id)).to_not be_nil
            expect(assigns(:more_data_available)).to eq(true)
          end
        end

        context "when signed in" do
          before do
            sign_in(FactoryBot.create(:user))
          end

          it "is fine" do
            # basic test to make sure nothing breaks with an user
            expect(subject).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
