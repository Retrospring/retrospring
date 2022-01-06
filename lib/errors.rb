module Errors
  class Base < StandardError
    def status
      500
    end

    def code
      @code ||= self.class.name.sub('Errors::', '').underscore
    end
  end

  class BadRequest < Base
    def status
      400
    end
  end

  class InvalidBanDuration < BadRequest
  end

  class Forbidden < Base
    def status
      403
    end
  end
end
