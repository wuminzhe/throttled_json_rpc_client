require "delegate"

class Limiter < SimpleDelegator
  def initialize(object, rate_queue)
    @queue = rate_queue
    super(object)
  end

  def method_missing(*args, **kwargs, &block)
    @queue.shift do
      super
    end
  end
end
