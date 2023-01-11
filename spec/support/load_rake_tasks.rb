# frozen_string_literal: true

# ensure Rake tasks are only loaded once during the entire RSpec run.
#
# when using it from a `before(:context) { ... }` block this will load the
# tasks more than once and therefore run tasks more often than they should ...
Rails.application.load_tasks
