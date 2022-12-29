# frozen_string_literal: true

require "rails_helper"

describe UseCase::DataExport::User, :data_export do
  let(:user_params) do
    {
      email:                             "fizzyraccoon@bsnss.biz",
      answered_count:                    144,
      asked_count:                       72,
      comment_smiled_count:              15,
      commented_count:                   12,
      confirmation_sent_at:              2.weeks.ago.utc,
      confirmed_at:                      2.weeks.ago.utc + 1.hour,
      created_at:                        2.weeks.ago.utc,
      current_sign_in_at:                8.hours.ago.utc,
      current_sign_in_ip:                "198.51.100.220",
      last_sign_in_at:                   1.hour.ago,
      last_sign_in_ip:                   "192.0.2.14",
      locale:                            "en",
      privacy_allow_anonymous_questions: true,
      privacy_allow_public_timeline:     false,
      privacy_allow_stranger_answers:    false,
      privacy_show_in_search:            true,
      screen_name:                       "fizzyraccoon",
      show_foreign_themes:               true,
      sign_in_count:                     10,
      smiled_count:                      28,
      profile:                           {
        display_name:      "Fizzy Raccoon",
        description:       "A small raccoon",
        location:          "Binland",
        motivation_header: "",
        website:           "https://retrospring.net"
      }
    }
  end

  it "returns the user as json" do
    expect(json_file("user.json")).to eq(
      {
        user:    {
          id:                                user.id,
          email:                             "fizzyraccoon@bsnss.biz",
          remember_created_at:               nil,
          sign_in_count:                     10,
          current_sign_in_at:                user.current_sign_in_at.as_json,
          last_sign_in_at:                   user.last_sign_in_at.as_json,
          current_sign_in_ip:                "198.51.100.220",
          last_sign_in_ip:                   "192.0.2.14",
          created_at:                        user.created_at.as_json,
          updated_at:                        user.updated_at.as_json,
          screen_name:                       "fizzyraccoon",
          asked_count:                       72,
          answered_count:                    144,
          commented_count:                   12,
          smiled_count:                      28,
          profile_picture_file_name:         nil,
          profile_picture_processing:        nil,
          profile_picture_x:                 nil,
          profile_picture_y:                 nil,
          profile_picture_w:                 nil,
          profile_picture_h:                 nil,
          privacy_allow_anonymous_questions: true,
          privacy_allow_public_timeline:     false,
          privacy_allow_stranger_answers:    false,
          privacy_show_in_search:            true,
          comment_smiled_count:              15,
          profile_header_file_name:          nil,
          profile_header_processing:         nil,
          profile_header_x:                  nil,
          profile_header_y:                  nil,
          profile_header_w:                  nil,
          profile_header_h:                  nil,
          locale:                            "en",
          confirmed_at:                      user.confirmed_at.as_json,
          confirmation_sent_at:              user.confirmation_sent_at.as_json,
          unconfirmed_email:                 nil,
          show_foreign_themes:               true,
          export_url:                        nil,
          export_processing:                 false,
          export_created_at:                 nil,
          otp_module:                        "disabled",
          privacy_lock_inbox:                false,
          privacy_require_user:              false,
          privacy_hide_social_graph:         false,
          privacy_noindex:                   false
        },
        profile: {
          display_name:      "Fizzy Raccoon",
          description:       "A small raccoon",
          location:          "Binland",
          website:           "https://retrospring.net",
          motivation_header: "",
          created_at:        user.profile.created_at.as_json,
          updated_at:        user.profile.updated_at.as_json,
          anon_display_name: nil
        },
        roles:   {
          administrator: false,
          moderator:     false
        }
      }
    )
  end

  it "does not have any pictures attached" do
    expect(subject.keys.select { _1.start_with?("pictures/") }).to be_empty
  end

  context "when user has a profile picture" do
    let(:user_params) do
      super().merge(
        process_profile_picture_upload: true, # force carrierwave_backgrounder to immediately process the image
        profile_picture:                Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/banana_racc.jpg"), "image/jpeg"),
        profile_picture_x:              571,
        profile_picture_y:              353,
        profile_picture_w:              474,
        profile_picture_h:              474
      )
    end

    it "includes the pictures in the file list" do
      expect(subject.keys.select { _1.start_with?("pictures/") }.sort).to eq([
        "pictures/profile_picture_original_banana_racc.jpg",
        "pictures/profile_picture_large_banana_racc.jpg",
        "pictures/profile_picture_medium_banana_racc.jpg",
        "pictures/profile_picture_small_banana_racc.jpg"
      ].sort)
    end

    it "contains the profile picture info on the exported user" do
      expect(json_file("user.json").fetch(:user)).to include(
        profile_picture_file_name: "banana_racc.jpg",
        profile_picture_x:         571,
        profile_picture_y:         353,
        profile_picture_w:         474,
        profile_picture_h:         474
      )
    end
  end

  context "when user has a profile header" do
    let(:user_params) do
      super().merge(
        process_profile_header_upload: true, # force carrierwave_backgrounder to immediately process the image
        profile_header:                Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/banana_racc.jpg"), "image/jpeg"),
        profile_header_x:              0,
        profile_header_y:              412,
        profile_header_w:              1813,
        profile_header_h:              423
      )
    end

    it "includes the pictures in the file list" do
      expect(subject.keys.select { _1.start_with?("pictures/") }.sort).to eq([
        "pictures/profile_header_original_banana_racc.jpg",
        "pictures/profile_header_web_banana_racc.jpg",
        "pictures/profile_header_mobile_banana_racc.jpg",
        "pictures/profile_header_retina_banana_racc.jpg"
      ].sort)
    end

    it "contains the profile header info on the exported user" do
      expect(json_file("user.json").fetch(:user)).to include(
        profile_header_file_name: "banana_racc.jpg",
        profile_header_x:         0,
        profile_header_y:         412,
        profile_header_w:         1813,
        profile_header_h:         423
      )
    end
  end
end
