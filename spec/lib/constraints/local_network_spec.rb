# frozen_string_literal: true

require "rails_helper"

describe Constraints::LocalNetwork do
  describe ".matches?" do
    let(:request) { double("Rack::Request", remote_ip:) }

    subject { described_class.matches?(request) }

    context "with a private address from the 10.0.0.0/8 range" do
      let(:remote_ip) { "10.0.2.100" }

      it { is_expected.to be_truthy }
    end

    context "with a private address from the 127.0.0.0/8 range" do
      let(:remote_ip) { "127.0.0.1" }

      it { is_expected.to be_truthy }
    end

    context "with a private address from the 172.16.0.0/12 range" do
      let(:remote_ip) { "172.31.33.7" }

      it { is_expected.to be_truthy }
    end

    context "with a private address from the 192.168.0.0/16 range" do
      let(:remote_ip) { "192.168.123.45" }

      it { is_expected.to be_truthy }
    end

    context "with a non-private/loopback address" do
      let(:remote_ip) { "193.186.6.83" }

      it { is_expected.to be_falsey }
    end

    context "with some fantasy address" do
      let(:remote_ip) { "fe80:3::1ff:fe23:4567:890a" }

      it { is_expected.to be_falsey }
    end

    context "with an actual invalid address" do
      let(:remote_ip) { "herbert" }

      it { is_expected.to be_falsey }
    end
  end
end
