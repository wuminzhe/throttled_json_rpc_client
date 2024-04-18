module JsonRpcClient
  class HttpError < StandardError; end
  class JSONRpcError < StandardError; end

  class << self
    def request(url, method, params)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
      request.body = { jsonrpc: "2.0", method: method, params: params, id: 1 }.to_json

      # https://docs.ruby-lang.org/en/master/Net/HTTPResponse.html
      response = http.request(request)
      raise HttpError, response unless response.is_a?(Net::HTTPOK)

      body = JSON.parse(response.body)
      raise JSONRpcError, body["error"] if body["error"]

      body["result"]
    end
  end

  class Eth
    attr_reader :url

    def initialize(url)
      @url = url
    end

    def get_block_by_bumber(block_number_or_block_tag, transaction_detail_flag = false)
      rpc_method = "eth_getBlockByNumber"
      params = [block_number_or_block_tag, transaction_detail_flag]
      JsonRpcClient.request(url, rpc_method, params)
    end

    # == get_block_by_bumber('latest'])['number']
    def block_number
      rpc_method = "eth_blockNumber"
      params = []
      JsonRpcClient.request(url, rpc_method, params)
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
      JsonRpcClient.request(url, rpc_method, params)
    end
  end
end
