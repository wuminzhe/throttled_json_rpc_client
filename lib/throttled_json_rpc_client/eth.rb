module ThrottledJsonRpcClient
  class Eth
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def get_block_by_bumber(block_number_or_block_tag, transaction_detail_flag = false)
      rpc_method = "eth_getBlockByNumber"
      params = [block_number_or_block_tag, transaction_detail_flag]
      ThrottledJsonRpcClient._json_rpc_request(url, rpc_method, params)
    end

    # == get_block_by_bumber('latest'])['number']
    def block_number
      rpc_method = "eth_blockNumber"
      params = []
      ThrottledJsonRpcClient._json_rpc_request(url, rpc_method, params)
    end

    #############################
    # use method_missing to define all the methods
    #############################
    def respond_to_missing?(*_args)
      true
    end

    # example:
    #   eth.get_balance('0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045', 'latest')
    def method_missing(method, *args)
      words = method.to_s.split("_")
      rpc_method = "eth_#{words[0]}#{words[1..].collect(&:capitalize).join}"
      params = args
      ThrottledJsonRpcClient._json_rpc_request(url, rpc_method, params)
    end

    # limit: #{rate} requests / #{interval} seconds
    def self.create(url, rate: 5, interval: 1, redis_urls: ["redis://localhost:6379/2"])
      rate_queue = DistributedRateQueue.new(
        redis_urls: redis_urls,
        key: "key:#{url}",
        rate: rate,
        interval: interval
      )

      Limiter.new(Eth.new(url), rate_queue)
    end
  end
end
