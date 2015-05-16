class TeapotError < NotImplementedError
  attr_reader :message, :status

  def initialize()
    super
    # QUALITY COMEDY
    @message = "I'm a teapot, please implement me."
    @stauts  = 418
  end
end
