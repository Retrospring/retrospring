# frozen_string_literal: true

# Retrospring's version scheme is based on CalVer
# because we don't really track/plan ahead feature releases
#
# The version is structured like this:
# YYYY.MMDD.PATCH
#
# PATCH being a zero-indexed number representing the
# amount of patch releases for the given day

module Retrospring
  module Version
    module_function

    def year = 2025

    def month = 2

    def day = 28

    def patch = 0

    def suffix = ""

    def minor = [month.to_s.rjust(2, "0"), day.to_s.rjust(2, "0")].join

    def source_url = APP_CONFIG[:source_url] || "https://github.com/retrospring/retrospring"

    def to_a = [year.to_s, minor, patch.to_s]

    def to_s = [to_a.join("."), suffix].join
  end
end
