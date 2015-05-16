class TeapotError < NotImplementedError
  attr_reader :message, :status

  def initialize()
    super
    # QUALITY COMEDY
    @message = "I'm a teapot, please implement me."
    @status  = 418
  end
end
