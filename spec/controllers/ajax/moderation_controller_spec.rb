# coding: utf-8
# frozen_string_literal: true

require "rails_helper"

describe Ajax::ModerationController, :ajax_controller, type: :controller do
  include ActiveSupport::Testing::TimeHelpers

  shared_examples "fails when report does not exist" do
    let(:report_id) { "Burgenland" }
    let(:expected_response) do
      {
        "success" => false,
        "status" => "not_found",
        "message" => anything
      }
    end

    include_examples "returns the expected response"
  end

  let(:target_user) { FactoryBot.create(:user) }
  let(:report) do
    Reports::User.create!(
      user: user,
      target_id: target_user.id
    )
  end
  let(:user_role) { :moderator }

  before do
    user.add_role user_role if user_role
    sign_in(user)
  end

  describe "#destroy_report" do
    let(:params) do
      {
        id: report_id
      }
    end

    subject { post(:destroy_report, params: params) }

    context "when report exists" do
      let(:report_id) { report.id }
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything
        }
      end

      before { report }

      it "does not actually destroy the report" do
        expect { subject }.to_not(change { Report.count })
      end

      it "only marks the report as deleted" do
        expect { subject }.to(change { report.reload.deleted }.from(false).to(true))
      end

      include_examples "returns the expected response"
    end

    it_behaves_like "fails when report does not exist"
  end

  describe "#ban" do
    let(:params) do
      {
        user: user_param,
        ban: ban,
        reason: "just a prank, bro",
        duration: duration,
        duration_unit: duration_unit,
      }
    end

    subject { post(:ban, params: params) }

    context "when user exists" do
      shared_examples "does not ban administrators" do
        let(:expected_response) do
          {
            "success" => false,
            "status" => "nopriv",
            "message" => anything
          }
        end

        before { target_user.add_role :administrator }

        it "does not ban the target user" do
          subject
          expect(target_user).not_to be_banned
        end

        include_examples "returns the expected response"
      end

      let(:user_param) { target_user.screen_name }
      let(:expected_response) do
        {
          "success" => true,
          "status" => "okay",
          "message" => anything
        }
      end

      before { target_user }

      context "when ban = 0" do
        let(:ban) { "0" }

        "01".each_char do |pb|
          context "when permaban = #{pb}" do
            let(:duration) { pb == '0' ? 3 : nil }
            let(:duration_unit) { pb == '0' ? 'hours' : nil }

            context "when user is already banned" do
              before { target_user.ban }

              it "unbans the user" do
                expect { subject }.to change { target_user.reload.banned? }.from(true).to(false)
              end

              include_examples "returns the expected response"
            end

            context "when user is not yet banned" do
              it "does not change the status of the ban" do
                expect { subject }.not_to(change { target_user.reload.banned? })
              end

              include_examples "returns the expected response"
            end
          end
        end
      end

      context "when ban = 1" do
        let(:ban) { "1" }

        context "when permaban = 0" do
          let(:duration) { 3 }
          let(:duration_unit) { 'hours' }

          it "bans the user for 3 hours" do
            freeze_time do
              expect { subject }.to change { target_user.reload.banned? }.from(false).to(true)
              expect(target_user.bans.current.first.reason).to eq("just a prank, bro")
              expect(target_user.bans.current.first.expires_at.to_i).to eq((Time.now.utc + 3.hours).to_i)
            end
          end

          include_examples "returns the expected response"

          it_behaves_like "does not ban administrators"
        end

        context "when permaban = 1" do
          let(:duration) { nil }
          let(:duration_unit) { nil }

          it "bans the user for all eternity" do
            expect { subject }.to change { target_user.reload.banned? }.from(false).to(true)
            expect(target_user.bans.current.first.reason).to eq("just a prank, bro")
            expect(target_user.bans.current.first.expires_at).to be_nil
          end

          include_examples "returns the expected response"

          it_behaves_like "does not ban administrators"
        end
      end
    end

    context "when reason = Spam" do
      let(:params) do
        {
          user: target_user.screen_name,
          ban: "1",
          reason: "Spam",
          duration: nil,
          duration_unit: nil,
        }
      end

      it "empties the user's profile" do
        user.profile.display_name = "Veggietales Facts"
        user.profile.description = "Are you a fan of Veggietales? Want to expand your veggie knowledge? Here at Veggietales Facts, we tweet trivia for fans like you."
        user.profile.location = "Hell"
        user.profile.website = "https://twitter.com/veggiefact"

        expect { subject }.to change { target_user.reload.banned? }.from(false).to(true)
        expect(target_user.bans.current.first.reason).to eq("Spam")

        expect(target_user.profile.display_name).to be_nil
        expect(target_user.profile.description).to be_empty
        expect(target_user.profile.location).to be_empty
        expect(target_user.profile.website).to be_empty
      end
    end

    context "when user does not exist" do
      let(:user_param) { "fritz-fantom" }
      let(:ban) { "1" }
      let(:duration) { nil }
      let(:duration_unit) { nil }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "not_found",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end

  describe "#privilege" do
    valid_role_pairs = {
      moderator: :moderator,
      admin: :administrator
    }.freeze

    let(:params) do
      {
        user: user_param,
        type: type,
        status: status
      }
    end

    subject { post(:privilege, params: params) }

    context "when user exists" do
      let(:user_param) { target_user.screen_name }
      before { target_user }

      {
        nil => "has no extra roles",
        :moderator => "is a moderator"
      }.each do |u_role, context_desc|
        context "when the current user #{context_desc}" do
          let(:user_role) { u_role }
          let(:expected_response) do
            {
              "success" => false,
              "status" => "nopriv",
              "message" => anything
            }
          end

          valid_role_pairs.each do |type, role_name|
            context "when type is #{type}" do
              let(:type) { type }

              context "when status is true" do
                let(:status) { "true" }

                it "does not modify the roles on the target user" do
                  expect { subject }.not_to(change { target_user.reload.roles.to_a })
                end

                include_examples "returns the expected response"
              end

              context "when status is false" do
                let(:status) { "true" }

                before { target_user.add_role role_name }

                it "does not modify the roles on the target user" do
                  expect { subject }.not_to(change { target_user.reload.roles.to_a })
                end

                include_examples "returns the expected response"
              end
            end
          end
        end
      end

      context "when the current user is an administrator" do
        let(:user_role) { :administrator }

        valid_role_pairs.each do |type, role_name|
          context "when type is #{type}" do
            let(:type) { type }

            context "when status is true" do
              let(:status) { "true" }
              let(:expected_response) do
                {
                  "success" => true,
                  "status" => "okay",
                  "message" => anything,
                  "checked" => true
                }
              end

              it "adds the #{role_name} role to the target user" do
                expect { subject }.to(change { target_user.roles.reload.to_a })
                expect(target_user).to have_role(role_name)
              end

              include_examples "returns the expected response"
            end

            context "when status is false" do
              let(:status) { "false" }
              let(:expected_response) do
                {
                  "success" => true,
                  "status" => "okay",
                  "message" => anything,
                  "checked" => false
                }
              end

              before { target_user.add_role role_name }

              it "removes the #{role_name} role from the target user" do
                expect { subject }.to(change { target_user.reload.roles.to_a })
                expect(target_user).not_to have_role(role_name)
              end

              include_examples "returns the expected response"
            end
          end
        end

        context "when type is some bogus value" do
          let(:type) { "some bogus value" }
          let(:expected_response) do
            {
              "success" => false,
              "status" => "err",
              "message" => anything
            }
          end

          %w[true false].each do |s|
            context "when status is #{s}" do
              let(:status) { s }

              it "does not modify the roles on the target user" do
                expect { subject }.not_to(change { target_user.reload.roles.to_a })
              end

              include_examples "returns the expected response"
            end
          end
        end
      end
    end

    context "when user does not exist" do
      let(:user_param) { "fritz-fantom" }
      let(:type) { "admin" }
      let(:status) { "true" }
      let(:expected_response) do
        {
          "success" => false,
          "status" => "not_found",
          "message" => anything
        }
      end

      include_examples "returns the expected response"
    end
  end
end
