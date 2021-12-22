require 'rails_helper'

RSpec.describe MuteRule, type: :model do
  describe "#applies_to?" do
    let(:user) { FactoryBot.create(:user) }
    let(:rule) { MuteRule.create(user: user, muted_phrase: "trial") }
    let(:question) { Question.create(user: user, content: "Did you know that the critically acclaimed MMORPG Final Fantasy XIV has a free trial, and includes the entirety of A Realm Reborn AND the award-winning Heavensward expansion up to level 60 with no restrictions on playtime?") }

    it "only returns true for questions matching a certain phrase" do
      expect(rule.applies_to?(question)).to be(true)
    end
  end
end
