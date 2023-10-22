# frozen_string_literal: true

require "rails_helper"

RSpec.describe AvatarComponent, type: :component do
  let(:user) { FactoryBot.create(:user) }

  it "renders an avatar" do
    expect(
      render_inline(described_class.new(user:, size: "sm")).to_html,
    ).to include(
      "no_avatar.png",
    )
  end

  it "gets the medium version of a profile picture if requested" do
    expect(
      render_inline(described_class.new(user:, size: "md")).to_html,
    ).to include(
      "medium/",
    )
  end

  it "gets the large version of a profile picture if requested" do
    expect(
      render_inline(described_class.new(user:, size: "xl")).to_html,
    ).to include(
      "large/",
    )
  end

  it "includes additionally passed classes" do
    expect(
      render_inline(described_class.new(user:, size: "md", classes: %w[first-class second-class])).to_html,
    ).to include(
      'class="avatar-md first-class second-class"',
    )
  end
end
