require "redlock"

# https://medium.com/@jaimersonn/throttling-api-calls-in-a-distributed-environment-76d2789a796d
class DistributedRateQueue
  attr_reader :lock_duration, :lock_manager, :key

  def initialize(redis_urls:, key:, rate: 60, interval: 60)
    @lock_duration = ((interval / rate.to_f) * 1000).to_i # Redlock deals with miliseconds
    @lock_manager = Redlock::Client.new(redis_urls)
    @key = key
  end

  def shift(&block)
    if lock_manager.lock(key, lock_duration)
      puts "timestamp: #{Time.now.to_i}"
      yield
    else
      # Logger.log("Lock not acquired, waiting for next turn...", Process.pid)
      wait_for_next_turn
      shift(&block)
    end
  end

  private

  def wait_for_next_turn
    wait = lock_manager.get_remaining_ttl_for_resource(key)
    return unless wait.positive?

    # Logger.log("Waiting for #{wait / 1000.0} seconds", Process.pid)
    Kernel.sleep(wait / 1000.0)
  end
end
