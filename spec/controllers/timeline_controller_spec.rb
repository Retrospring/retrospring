# frozen_string_literal: true

require "rails_helper"

describe TimelineController do
  let(:user) { FactoryBot.create(:user) }

  let!(:followed_users) { FactoryBot.create_list(:user, 3) }
  let!(:followed_user_answers) { followed_users.map { |u| FactoryBot.create_list(:answer, 5, user: u) }.flatten }

  let!(:unfollowed_users) { FactoryBot.create_list(:user, 3) }
  let!(:unfollowed_user_answers) { unfollowed_users.map { |u| FactoryBot.create_list(:answer, 5, user: u) }.flatten }

  let!(:listed_users) { [followed_users[0], unfollowed_users[0], unfollowed_users[1]] }
  let!(:listed_user_answers) { listed_users.map(&:answers).flatten }
  let(:list) { FactoryBot.create(:list, user: user, members: listed_users, display_name: "Test List") }

  before do
    sign_in(user)

    followed_users.each { |u| user.follow(u) }
    stub_const("APP_CONFIG", {
                 "site_name"      => "Specspring",
                 "hostname"       => "test.host",
                 "https"          => false,
                 "items_per_page" => 10
               })
  end

  shared_examples_for "paginates" do |answer_set, last_page_start_index = 5, expected_last_page_size = 5, should_test_single_page = true|
    context "can't display all answers on one page" do
      let(:last_id) { nil }

      it { should have_http_status(200) }

      it "paginates" do
        subject
        expect(assigns(:more_data_available)).to eq(true)
        expect(assigns(:timeline).length).to eq(10)
      end
    end

    context "fetching the last page" do
      let(:last_id) do
        if answer_set.is_a?(Symbol)
          public_send(answer_set).sort_by(&:id)[last_page_start_index].id
        else
          answer_set.sort_by(&:id)[last_page_start_index].id
        end
      end

      it "loads the last page" do
        subject
        expect(assigns(:more_data_available)).to eq(false)
        expect(assigns(:timeline).length).to eq(expected_last_page_size)
      end
    end

    if should_test_single_page
      context "can display all answers on one page" do
        before do
          if answer_set.is_a?(Symbol)
            public_send(answer_set).last(6).each(&:destroy!)
          else
            answer_set.last(6).each(&:destroy!)
          end
        end

        it { should have_http_status(200) }

        it "does not paginate" do
          subject
          expect(assigns(:more_data_available)).to eq(false)
          expect(assigns(:timeline).length).to eq(9)
        end
      end
    end
  end

  shared_examples_for "assigns title" do |expected_prefix|
    it "assigns the list and title to an instance variable" do
      subject
      expect(assigns(:title)).to eq("#{expected_prefix} | Specspring")
    end
  end

  describe "#index" do
    subject { get :index, params: params }

    let(:params) { { last_id: last_id } }
    let(:last_id) { nil }

    it { should have_http_status(200) }
    it_behaves_like "paginates", :followed_user_answers
  end

  describe "#list" do
    subject { get :list, params: params }

    context "viewing a list" do
      let(:params) { { list_name: list.name, last_id: last_id } }
      let(:last_id) { nil }

      it_behaves_like "paginates", :listed_user_answers
      it_behaves_like "assigns title", "Test List"

      it "assigns the list to an instance variable" do
        subject
        expect(assigns(:list)).to eq(list)
      end
    end
  end

  describe "#public" do
    subject { get :public, params: params }

    context "viewing public timeline" do
      let(:params) { { last_id: last_id } }
      let(:last_id) { nil }

      it_behaves_like "paginates", Answer.all.order(created_at: :desc), 10, 10, false
      it_behaves_like "assigns title", "Public Timeline"
    end
  end
end
