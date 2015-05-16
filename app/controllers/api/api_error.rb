module API::APIError < StandardError
  attr_reader :status

  def initialize(status)
    super
    @status = status
  end
end
