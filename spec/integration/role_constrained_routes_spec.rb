# frozen_string_literal: true

require "rails_helper"
require "support/pghero_stubby"

describe "role-constrained routes", type: :request do
  shared_examples_for "fails to access route" do
    it "fails to access route" do
      # 302 = redirect to login
      # 404 = no user found -- we have a fallback route if something could not be matched
      result = begin; subject; rescue ActionController::RoutingError; :no_route; end
      expect(result).to be_in [302, 404, :no_route]
    end
  end

  shared_examples_for "routes for" do |roles, subject_block, skip_reason: nil|
    before { skip(skip_reason) } if skip_reason

    subject(&subject_block)

    context "not signed in" do
      include_examples "fails to access route"
    end

    roles.each do |role|
      context "signed in user without #{role} role" do
        let(:user) { FactoryBot.create(:user, password: "test1234") }

        before(:each) do
          post "/sign_in", params: { user: { login: user.email, password: user.password } }
        end

        include_examples "fails to access route"
      end

      context "signed in user with #{role} role" do
        let(:user) { FactoryBot.create(:user, password: "test1234", roles: [role]) }

        before(:each) do
          post "/sign_in", params: { user: { login: user.email, password: user.password } }
        end

        it "can access route" do
          expect(subject).to be_in 200..299
        end
      end
    end
  end

  it_behaves_like("routes for", [:administrator], -> { get("/justask_admin") })
  it_behaves_like("routes for", [:administrator], -> { get("/sidekiq") })
  it_behaves_like("routes for", [:administrator], -> { get("/pghero") })
end
