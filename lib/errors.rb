module Errors
  class Base < StandardError
    def status
      500
    end

    def code
      @code ||= self.class.name.sub('Errors::', '').underscore
    end

    def locale_tag
      @locale_tag ||= "errors.#{code}"
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

  class SelfAction < Forbidden
  end

  class FollowingSelf < SelfAction
  end

  class NotFound < Base
    def status
      404
    end
  end

  class UserNotFound < NotFound
  end

  # region User Blocking
  class Blocked < Forbidden
  end

  class OtherBlockedSelf < Blocked
  end

  class BlockingSelf < SelfAction
  end

  class AskingOtherBlockedSelf < OtherBlockedSelf
  end

  class FollowingOtherBlockedSelf < OtherBlockedSelf
  end

  class SelfBlockedOther < Blocked
  end

  class AskingSelfBlockedOther < SelfBlockedOther
  end

  class FollowingSelfBlockedOther < SelfBlockedOther
  end

  class AnsweringOtherBlockedSelf < OtherBlockedSelf
  end

  class AnsweringSelfBlockedOther < SelfBlockedOther
  end

  class CommentingSelfBlockedOther < SelfBlockedOther
  end

  class CommentingOtherBlockedSelf < OtherBlockedSelf
  end

  class ReactingSelfBlockedOther < SelfBlockedOther
  end

  class ReactingOtherBlockedSelf < OtherBlockedSelf
  end
  # endregion
end
