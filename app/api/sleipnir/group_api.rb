class Sleipnir::GroupAPI < Sleipnir::MountAPI
  include Sleipnir::Concerns

  helpers Sleipnir::Helpers

  namespace :group do
    # TODO: look at the group ajax and figure out wtf is allowed.
  end
end
