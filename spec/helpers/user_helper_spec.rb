# frozen_string_literal: true

require "rails_helper"

describe UserHelper, type: :helper do
  describe "#user_screen_name" do
    subject do
      helper.user_screen_name(user,
                              context_user:      context_user,
                              author_identifier: author_identifier,
                              url:               url,
                              link_only:         link_only)
    end

    let(:user) { FactoryBot.create(:user) }
    let(:context_user) { nil }
    let(:author_identifier) { nil }
    let(:url) { true }
    let(:link_only) { false }

    before do
      stub_const("APP_CONFIG", {
                   "anonymous_name" => "Anonymous"
                 })
    end

    context "moderation view enabled" do
      before do
        allow(helper).to receive(:moderation_view?).and_return(true)
      end

      context "question was asked anonymously" do
        let(:author_identifier) { "some_identifier" }

        context "while logged in" do
          let(:user) { FactoryBot.create(:user) }

          context "user is not banned" do
            it "unmasks the author" do
              expect(subject).to eq(link_to(user.profile.safe_name, show_user_profile_path(user.screen_name), class: ""))
            end
          end

          context "user is banned" do
            before do
              user.ban
            end

            it "unmasks the author" do
              expect(subject).to eq(link_to(user.profile.safe_name, show_user_profile_path(user.screen_name), class: "user--banned"))
            end
          end
        end

        context "while not logged in" do
          let(:user) { nil }

          context "context user has custom anonymous name" do
            let(:context_user) { FactoryBot.create(:user, profile: { anon_display_name: "Sneaky Raccoon" }) }

            it "reveals the identifier and shows the custom name" do
              expect(subject).to eq(content_tag(:abbr, "Sneaky Raccoon", title: "some_identifier"))
            end
          end

          context "context user doesn't have a custom anonymous name" do
            it "reveals the identifier and shows the default name" do
              expect(subject).to eq(content_tag(:abbr, "Anonymous", title: "some_identifier"))
            end
          end
        end
      end
    end

    context "moderation view disabled" do
      before do
        allow(helper).to receive(:moderation_view?).and_return(false)
      end

      context "author is anonymous" do
        let(:author_identifier) { "some_identifier" }

        let(:context_user) { FactoryBot.create(:user, profile: { anon_display_name: anon_display_name }) }
        context "context user has custom anonymous name" do
          let(:anon_display_name) { "Sneaky Raccoon" }

          it "returns the custom anonymous name" do
            expect(subject).to eq("Sneaky Raccoon")
          end
        end

        context "context user has custom anonymous name containing a HTML tag" do
          let(:anon_display_name) { "Sneaky <b>Raccoon</b>" }

          it "returns the sanitized custom anonymous name" do
            expect(subject).to eq("Sneaky Raccoon")
          end
        end

        context "context user doesn't have a custom anonymous name" do
          let(:anon_display_name) { nil }

          it "returns the default anonymous name" do
            expect(subject).to eq("Anonymous")
          end
        end
      end

      context "author is not anonymous" do
        context "url is true" do
          let(:url) { true }

          context "link_only is true" do
            let(:link_only) { true }

            it "returns the url to the user's profile" do
              expect(subject).to eq(show_user_profile_path(user.screen_name))
            end
          end

          context "link_only is false" do
            let(:link_only) { false }

            context "user is not banned" do
              it "returns a link tag to the user's profile" do
                expect(subject).to eq(link_to(user.profile.safe_name, show_user_profile_path(user.screen_name), class: ""))
              end
            end

            context "user is banned" do
              before do
                user.ban
              end

              it "returns a link tag to the user's profile" do
                expect(subject).to eq(link_to(user.profile.safe_name, show_user_profile_path(user.screen_name), class: "user--banned"))
              end
            end
          end
        end

        context "url is false" do
          let(:url) { false }

          it "returns the user's profile name" do
            expect(subject).to eq(user.profile.safe_name.strip)
          end
        end
      end
    end
  end
end
