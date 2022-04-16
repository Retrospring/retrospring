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

    def year
      2022
    end

    def month
      4
    end

    def day
      15
    end

    def patch
      0
    end

    def suffix
      ""
    end

    def minor
      [month.to_s.rjust(2, "0"), day.to_s.rjust(2, "0")].join
    end

    def to_a
      [year.to_s, minor, patch.to_s]
    end

    def to_s
      [to_a.join("."), suffix].join
    end
  end
end