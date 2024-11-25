require "faraday"
require "json"
require "time"

class JsonRpcClient
  class RpcError < StandardError; end

  DEFAULT_MAX_BATCH_SIZE = 100
  DEFAULT_TIMEOUT = 30

  def initialize(
    endpoint,
    timeout: DEFAULT_TIMEOUT,
    max_batch_size: DEFAULT_MAX_BATCH_SIZE,
    headers: {}
  )
    @endpoint = endpoint
    @max_batch_size = max_batch_size
    @timeout = timeout
    @headers = { "Content-Type" => "application/json" }.merge(headers)
    @request_id = 0
    @last_request_time = Time.now
    @request_times = []
  end

  def call(method, params = nil)
    payload = build_request(method, params)
    response = make_request(payload)

    raise RpcError, "RPC error: #{response["error"]}" if response["error"]

    response["result"]
  end

  def batch_call(calls)
    if calls.size > @max_batch_size
      raise RpcError,
            "Batch size #{calls.size} exceeds maximum allowed size of #{@max_batch_size}"
    end

    results = []
    batch_payload = calls.map do |method, params|
      build_request(method, params)
    end

    responses = make_request(batch_payload)

    # Handle single response case
    responses = [responses] unless responses.is_a?(Array)

    # Sort responses by id to maintain order
    sorted_responses = responses.sort_by { |r| r["id"] }

    sorted_responses.each do |response|
      raise RpcError, "RPC error in batch: #{response["error"]}" if response["error"]

      results << response["result"]
    end

    results
  end

  private

  def build_request(method, params)
    @request_id += 1
    {
      jsonrpc: "2.0",
      method: method,
      params: params || [],
      id: @request_id
    }
  end

  def make_request(payload)
    connection = Faraday.new(@endpoint) do |conn|
      conn.options.timeout = @timeout
      conn.ssl.verify = false
      conn.adapter Faraday.default_adapter
    end

    response = connection.post do |req|
      req.headers = @headers
      req.body = payload.to_json
    end

    raise RpcError, "HTTP error: #{response.status} - #{response.body}" unless response.success?

    JSON.parse(response.body)
  rescue Faraday::TimeoutError => e
    raise RpcError, "Request timed out after #{@timeout} seconds"
  rescue Faraday::ConnectionFailed => e
    raise RpcError, "Connection failed: #{e.message}"
  rescue Faraday::SSLError => e
    raise RpcError, "SSL Error: #{e.message}"
  end
end
