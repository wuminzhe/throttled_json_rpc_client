require "delegate"

module ThrottledJsonRpcClient
  class Eth < SimpleDelegator
    # limit: #{rate} requests / #{interval} seconds
    def initialize(
      url,
      rate: 5, interval: 1, redis_urls: ["redis://localhost:6379/2"],
      logger: Logger.new($stdout, level: :info)
    )
      @queue = DistributedRateQueue.new(
        redis_urls: redis_urls,
        key: "key:#{url}",
        rate: rate,
        interval: interval
      )

      super(JsonRpcClient::Eth.new(url, logger: logger))
    end

    def method_missing(*args, **kwargs, &block)
      @queue.shift do
        super
      end
    end
  end
end
