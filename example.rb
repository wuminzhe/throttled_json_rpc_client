require "logger"

rpc_url = "https://1rpc.io/eth"

eth = ThrottledJsonRpcClient::Eth.new(
  rpc_url,
  redis_urls: ["redis://redis:6379/2"],
  logger: Logger.new($stdout, level: :debug)
)

threads = []
10.times do
  threads << Thread.new do
    p eth.block_number
  end
end
threads.map(&:join)
