# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(List, type: :model) do
  let(:user) { FactoryBot.build(:user) }

  describe 'name mangling' do
    subject do
      List.new(user: user, display_name: display_name).tap(&:validate)
    end

    {
      'great list' => 'great-list',
      'followers' => '-followers-',
      '  followers  ' => '-followers-',
      "  the game  \t\nyes" => 'the-game-yes',

      # not nice, but this is just the way it is:
      "\u{1f98a} :3" => '3',
      "\u{1f98a}" => ''
    }.each do |display_name, expected_name|
      context "when display name is #{display_name.inspect}" do
        let(:display_name) { display_name }

        its(:name) { should eq expected_name }
      end
    end
  end

  describe 'validations' do
    subject do
      List.new(user: user, display_name: display_name).validate
    end

    context "when display name is 'great list' (valid)" do
      let(:display_name) { 'great list' }

      it { is_expected.to be true }
    end

    context "when display name is '1' (valid)" do
      let(:display_name) { '1' }

      it { is_expected.to be true }
    end

    context 'when display name is the letter E 621 times (invalid, too long)' do
      let(:display_name) { 'E' * 621 }

      it { is_expected.to be false }
    end

    context 'when display name is an empty string (invalid, as `name` would be empty)' do
      let(:display_name) { '' }

      it { is_expected.to be false }
    end

    context "when display name is \u{1f98a} (invalid, as `name` would be empty)" do
      let(:display_name) { "\u{1f98a}" }

      it { is_expected.to be false }
    end
  end
end
