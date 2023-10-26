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

RSpec.shared_examples_for "turbo does not succeed" do |part_of_error_message|
  it "turbo does not succeed" do
    subject
    # FIXME: for some reason, partials are not rendered, making the actual error message not accessible
    expect(response.body).to include "turbo-stream action=\"append\" target=\"toasts\""
  end
end
