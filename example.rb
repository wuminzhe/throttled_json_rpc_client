rpc_url = "https://1rpc.io/eth"

# limit: 1request / 5s
rate_queue = DistributedRateQueue.new(
  redis_urls: ["redis://redis:6379/2"],
  key: "key:#{rpc_url}",
  rate: 1,
  interval: 5
)

eth = Limiter.new(
  ThrottledJsonRpcClient::Eth.new(rpc_url),
  rate_queue
)

# eth = build_throttled_client(rpc_url, {})

threads = []
10.times do
  threads << Thread.new do
    p eth.block_number
  end
end
threads.map(&:join)
