require "rails_helper"

describe BootstrapHelper, :type => :helper do
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

    it 'should only include an icon if wanted' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(nav_entry('Example', '/example', icon: 'beaker', icon_only: true)).to(
        eq('<li class="nav-item "><a class="nav-link" href="/example"><i class="fa fa-beaker" title="Example"></i></a></li>')
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

  describe "#list_group_item" do
    it 'should return a HTML navigation item which links to a given address' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(list_group_item('Example', '/example')).to(
        eq('<a href="/example" class="list-group-item list-group-item-action ">Example</a>')
      )
    end

    it 'should return with an active attribute if the link matches the current URL' do
      allow(self).to receive(:current_page?).and_return(true)
      expect(list_group_item('Example', '/example')).to(
        eq('<a href="/example" class="list-group-item list-group-item-action active ">Example</a>')
      )
    end

    it 'should include a badge if given' do
      allow(self).to receive(:current_page?).and_return(false)
      expect(list_group_item('Example', '/example', badge: 3)).to(
        eq('<a href="/example" class="list-group-item list-group-item-action ">Example <span class="badge">3</span></a>')
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

  describe "#tooltip" do
    it 'should return the proper markup' do
      expect(tooltip("Example Text", "This is in a tooltip")).to eq("<span title=\"This is in a tooltip\" data-toggle=\"tooltip\" data-placement=\"bottom\">Example Text</span>")
    end
  end

  describe "#time_tooltip" do
    it 'should return a tooltip with proper time values' do
      Timecop.freeze(Time.utc(1984)) do
        @user = FactoryBot.create(:user)
        Timecop.travel(Time.now.utc + 10.minutes)

        expect(time_tooltip(@user)).to eq("<span title=\"Sun, 01 Jan 1984 00:00:00 +0000\" data-toggle=\"tooltip\" data-placement=\"bottom\">10 minutes</span>")
      end
    end
  end

  describe "#hidespan" do
    it 'should return the proper markup' do
      expect(hidespan("Hidden Text", "d-none")).to eq("<span class=\"d-none\">Hidden Text</span>")
    end
  end
end