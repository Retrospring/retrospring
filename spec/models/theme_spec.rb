# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Theme, type: :model) do
  context 'user-defined theme' do
    let(:user) { FactoryBot.create(:user) }
    let(:theme) { FactoryBot.create(:theme, user: user) }

    describe '#theme_color' do
      subject { theme.theme_color }

      it 'should return the theme\'s primary colour as a hex triplet' do
        expect(subject).to eq('#8e8cd8')
      end
    end

    describe '#mobile_theme_color' do
      subject { theme.mobile_theme_color }

      it 'should return the theme\'s background colour as a hex triplet' do
        expect(subject).to eq('#c6c5eb')
      end
    end
  end
end