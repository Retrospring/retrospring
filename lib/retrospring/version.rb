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

    def year = 2023

    def month = 1

    def day = 2

    def patch = 1

    def suffix = ""

    def minor = [month.to_s.rjust(2, "0"), day.to_s.rjust(2, "0")].join

    def to_a = [year.to_s, minor, patch.to_s]

    def to_s = [to_a.join("."), suffix].join
  end
end
