# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, :type => :helper do
  describe "#bootstrap_color" do
    it 'should map error and alert to danger' do
      expect(bootstrap_color("error")).to eq("danger")
      expect(bootstrap_color("alert")).to eq("danger")
    end

    it 'should map notice to info' do
      expect(bootstrap_color("notice")).to eq("info")
    end

    it 'should return any uncovered value' do
      expect(bootstrap_color("success")).to eq("success")
    end
  end

  describe "#user_opengraph" do
    context "sample user" do
      let(:user) { FactoryBot.create(:user,
                                     display_name: 'Cunes',
                                     bio: 'A bunch of raccoons in a trenchcoat.',
                                     screen_name: 'raccoons') }

      subject { user_opengraph(user) }


      it 'should generate a matching OpenGraph structure for a user' do
        allow(APP_CONFIG).to receive(:[]).with('site_name').and_return('pineapplespring')
        expect(subject).to eq(<<-EOS.chomp)
<meta property="og:title" content="Cunes" />
<meta property="og:type" content="profile" />
<meta property="og:image" content="http://test.host/images/large/no_avatar.png" />
<meta property="og:url" content="http://test.host/raccoons" />
<meta property="og:description" content="A bunch of raccoons in a trenchcoat." />
<meta property="og:site_name" content="pineapplespring" />
<meta property="profile:username" content="raccoons" />
EOS
      end
    end
  end
end