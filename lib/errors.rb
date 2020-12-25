# frozen_string_literal: true

module Errors
  class Base < StandardError
    def status
      500
    end

    def code
      @code ||= self.class.name.sub("Errors::", "").underscore
    end
  end

  class BadRequest < Base
    def status
      400
    end
  end

  class NotAuthorized < Base
    def status
      401
    end
  end

  class Forbidden < Base
    def status
      403
    end
  end
end
