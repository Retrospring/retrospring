# frozen_string_literal: true

# in spec/integration/role_constrained_routes_spec.rb we test for access to
# the pghero route, which fails because the PgHero::HomeController performs
# some queries which do not seem to work in a transaction
#
# since we don't need PgHero to work in tests stubbing it away should be^W^W
# is expected to be fine ;-)
class PgHero::HomeController
  def index
    render plain: "DB < ÖBB"
  end

  def set_database; end

  def set_query_stats_enabled; end

  def set_show_details; end
end
