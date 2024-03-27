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
      method = "eth_getBlockByNumber"
      params = [block_number_or_block_tag, transaction_detail_flag]
      json_rpc_request(url, method, params)
    end

    # == get_block_by_bumber('latest'])['number']
    def block_number
      method = "eth_blockNumber"
      params = []
      json_rpc_request(url, method, params)
    end
  end
end
