# frozen_string_literal: true

RSpec.shared_examples_for "raises an error" do |error_klass|
  it "raises an error" do
    expect { subject }.to raise_error(kind_of(error_klass))
  end
end

RSpec.shared_examples_for "ajax does not succeed" do |part_of_error_message|
  it "ajax does not succeed" do
    subject
    expect(assigns(:response)[:success]).to be false
    expect(assigns(:response)[:message]).to include(part_of_error_message)
  end
end
