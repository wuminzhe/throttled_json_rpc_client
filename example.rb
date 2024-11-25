rpc_url = "https://eth.llamarpc.com"

# limit: 1 request / 5 seconds
client = ThrottledJsonRpcClient::Client.new(
  rpc_url,
  rate: 1,
  interval: 5,
  redis_urls: ["redis://localhost:6379/2"]
)

threads = []
10.times do
  threads << Thread.new do
    p client.call("eth_blockNumber", [])
  end
end
threads.map(&:join)
