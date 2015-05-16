module API::TeapotError < NotImplementedError
  attr_reader :message

  def initialize()
    super
    # QUALITY COMEDY
    @message = "I'm a teapot, please implement me."
  end
end
