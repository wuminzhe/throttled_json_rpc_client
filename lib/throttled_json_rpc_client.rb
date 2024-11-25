# frozen_string_literal: true

require "delegate"
require_relative "limiter/distributed_rate_queue"
require_relative "json_rpc_client"
require_relative "throttled_json_rpc_client/version"

module ThrottledJsonRpcClient
  class Client < SimpleDelegator
    DEFAULT_MAX_RETRIES = 3
    DEFAULT_BASE_DELAY = 1 # Base delay in seconds

    # limit: #{rate} requests / #{interval} seconds
    def initialize(
      endpoint,
      timeout: JsonRpcClient::DEFAULT_TIMEOUT,
      max_batch_size: JsonRpcClient::DEFAULT_MAX_BATCH_SIZE,
      headers: {},
      # retry params
      max_retries: DEFAULT_MAX_RETRIES,
      base_delay: DEFAULT_BASE_DELAY,
      # limit params
      rate: 5, 
      interval: 1, # in seconds
      redis_urls: ["redis://localhost:6379/2"]
    )
      @max_retries = max_retries
      @base_delay = base_delay
      @queue = DistributedRateQueue.new(
        redis_urls: redis_urls,
        key: "key:#{endpoint}",
        rate: rate,
        interval: interval
      )
      super(
        JsonRpcClient.new(
          endpoint, 
          timeout: timeout, 
          max_batch_size: max_batch_size, 
          headers: headers
        )
      )
    end

    def call(method, params = nil)
      retries = 0
      begin
        @queue.shift do
          super(method, params)
        end
      rescue JsonRpcClient::RpcError => e
        retries += 1
        if retries <= @max_retries
          delay = @base_delay * (2**(retries - 1))
          sleep(delay)
          retry
        end
        raise e
      end
    end

    def batch_call(calls)
      retries = 0
      begin
        @queue.shift do
          super(calls)
        end
      rescue JsonRpcClient::RpcError => e
        retries += 1
        if retries <= @max_retries
          delay = @base_delay * (2**(retries - 1))
          sleep(delay)
          retry
        end
        raise e
      end
    end
  end
end