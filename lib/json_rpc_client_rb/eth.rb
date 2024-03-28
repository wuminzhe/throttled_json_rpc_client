module JsonRpcClientRb
  # eth = JsonRpcClientRb::Eth.new('https://1rpc.io/eth')
  # eth.get_block_by_bumber('latest')
  class Eth
    include JsonRpcClientRb

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def get_block_by_bumber(block_number_or_block_tag, transaction_detail_flag = false)
      rpc_method = "eth_getBlockByNumber"
      params = [block_number_or_block_tag, transaction_detail_flag]
      request(url, rpc_method, params)
    end

    # == get_block_by_bumber('latest'])['number']
    def block_number
      rpc_method = "eth_blockNumber"
      params = []
      request(url, rpc_method, params)
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
      request(url, rpc_method, params)
    end

    # def rate_limited_block_number
    #   JsonRpcClientRb.rate_limit(key: "rate_limit:#{url}") do
    #     block_number
    #   end
    # end
  end
end
