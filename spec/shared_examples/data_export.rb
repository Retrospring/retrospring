# frozen_string_literal: true

require "json"

RSpec.shared_context "DataExport" do
  let(:user_params) { {} }

  let!(:user) { FactoryBot.create(:user, **user_params) }

  subject { described_class.call(user:) }

  def json_file(filename) = JSON.parse(subject[filename], symbolize_names: true)
end

RSpec.configure do |c|
  c.include_context "DataExport", data_export: true
end
