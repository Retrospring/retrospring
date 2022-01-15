# frozen_string_literal: true

require 'rails_helper'
require 'exporter'

RSpec.describe Exporter do
  let(:params) { {
    answered_count: 144,
    asked_count: 72,
    ban_reason: nil,
    banned_until: nil,
    comment_smiled_count: 15,
    commented_count: 12,
    confirmation_sent_at: 2.weeks.ago.utc,
    confirmed_at: 2.weeks.ago.utc + 1.hour,
    created_at: 2.weeks.ago.utc,
    current_sign_in_at: 8.hours.ago.utc,
    current_sign_in_ip: '198.51.100.220',
    last_sign_in_at: 1.hour.ago,
    last_sign_in_ip: '192.0.2.14',
    locale: 'en',
    permanently_banned: false,
    privacy_allow_anonymous_questions: true,
    privacy_allow_public_timeline: false,
    privacy_allow_stranger_answers: false,
    privacy_show_in_search: true,
    screen_name: 'fizzyraccoon',
    show_foreign_themes: true,
    sign_in_count: 10,
    smiled_count: 28,
    profile: {
      display_name: 'Fizzy Raccoon',
      description: 'A small raccoon',
      location: 'Binland',
      motivation_header: '',
      website: 'https://retrospring.net',
    } } }
  let(:user) { FactoryBot.create(:user,
                                 **params) }
  let(:instance) { described_class.new(user) }

  describe '#collect_user_info' do
    subject { instance.send(:collect_user_info) }

    context 'exporting a user' do
      it "collects user info" do
        subject
        expect(instance.instance_variable_get(:@obj)).to eq(params.merge({
                                                                           administrator: false,
                                                                           moderator: false,
                                                                           id: user.id,
                                                                           updated_at: user.updated_at,
                                                                           profile_header: user.profile_header,
                                                                           profile_header_file_name: nil,
                                                                           profile_header_h: nil,
                                                                           profile_header_w: nil,
                                                                           profile_header_x: nil,
                                                                           profile_header_y: nil,
                                                                           profile_picture_file_name: nil,
                                                                           profile_picture_h: nil,
                                                                           profile_picture_w: nil,
                                                                           profile_picture_x: nil,
                                                                           profile_picture_y: nil,
                                                                         }))
      end
    end
  end
end
