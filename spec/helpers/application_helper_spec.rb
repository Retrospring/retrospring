# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, :type => :helper do
  describe '#nav_entry' do
    it 'should return a HTML navigation item which links to a given address' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(nav_entry('Example', '/example')).to(
        eq('<li class="nav-item "><a class="nav-link" href="/example">Example</a></li>')
      )
    end

    it 'should return with an active attribute if the link matches the current URL' do
      allow(self).to receive(:current_page?).and_return(true)
      expect(nav_entry('Example', '/example')).to(
        eq('<li class="nav-item active "><a class="nav-link" href="/example">Example</a></li>')
      )
    end

    it 'should include an icon if given' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(nav_entry('Example', '/example', icon: 'beaker')).to(
        eq('<li class="nav-item "><a class="nav-link" href="/example"><i class="fa fa-beaker"></i> Example</a></li>')
      )
    end

    it 'should include a badge if given' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(nav_entry('Example', '/example', badge: 3)).to(
        eq('<li class="nav-item "><a class="nav-link" href="/example">Example <span class="badge">3</span></a></li>')
      )

      expect(nav_entry('Example', '/example', badge: 3, badge_color: 'primary', badge_pill: true)).to(
        eq('<li class="nav-item "><a class="nav-link" href="/example">Example <span class="badge badge-primary badge-pill">3</span></a></li>')
      )
    end
  end

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
                                     profile: { display_name: 'Cunes',
                                                description: 'A bunch of raccoons in a trenchcoat.' },
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

  describe "#user_twitter_card" do
    context "sample user" do
      let(:user) { FactoryBot.create(:user,
                                     profile: {
                                       display_name: '',
                                       description: 'A bunch of raccoons in a trenchcoat.'},
                                     screen_name: 'raccoons') }

      subject { user_twitter_card(user) }
      it 'should generate a matching OpenGraph structure for a user' do
        expect(subject).to eq(<<-EOS.chomp)
<meta name="twitter:card" content="summary" />
<meta name="twitter:site" content="@retrospring" />
<meta name="twitter:title" content="Ask me anything!" />
<meta name="twitter:description" content="Ask raccoons anything on Retrospring" />
<meta name="twitter:image" content="http://test.host/images/large/no_avatar.png" />
EOS
      end
    end
  end

  describe "#answer_opengraph" do
    context "sample user and answer" do
      let!(:user) { FactoryBot.create(:user,
                                     display_name: '',
                                     bio: 'A bunch of raccoons in a trenchcoat.',
                                     screen_name: 'raccoons') }
      let(:answer) { FactoryBot.create(:answer,
                                       user_id: user.id,) }

      subject { answer_opengraph(answer) }

      it 'should generate a matching OpenGraph structure for a user' do
        allow(APP_CONFIG).to receive(:[]).with('site_name').and_return('pineapplespring')
        expect(subject).to eq(<<-EOS.chomp)
<meta property="og:title" content="raccoons answered: #{answer.question.content}" />
<meta property="og:type" content="article" />
<meta property="og:image" content="http://test.host/images/large/no_avatar.png" />
<meta property="og:url" content="http://test.host/raccoons/a/#{answer.id}" />
<meta property="og:description" content="#{answer.content}" />
<meta property="og:site_name" content="pineapplespring" />
EOS
      end
    end
  end
  
  describe "#rails_admin_path_for_resource" do
    context "user resource" do
      let(:resource) { FactoryBot.create(:user) }
      subject { rails_admin_path_for_resource(resource) }

      it "should return a URL to the given resource within rails admin" do
        expect(subject).to eq("/justask_admin/user/#{resource.id}")
      end
    end
  end
end
