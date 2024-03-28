# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

require_relative "limiter/distributed_rate_queue"
require_relative "limiter/limiter"

require_relative "json_rpc_client_rb/version"
require_relative "json_rpc_client_rb/eth"

module JsonRpcClientRb
  class HttpError < StandardError; end
  class JSONRpcError < StandardError; end

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

  # ttl is in ms
  # 10 requests/1s => 0.1s => 100ms
  #  1 requests/5s =>   5s => 5000ms
  def throttle(url:, ttl: 5000, &block)
    lock_manager = Redlock::Client.new(["redis://127.0.0.1:73"])

    lock_manager.lock!("throttle_key:#{url}", ttl, &block)
  rescue Redlock::LockError
    # error handling
    puts "throttle error"
  end
end
