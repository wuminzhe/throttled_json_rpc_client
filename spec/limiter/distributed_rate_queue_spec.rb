require "spec_helper"
require "timecop"
require "redis"

RSpec.describe DistributedRateQueue do
  let(:redis_urls) { ["redis://redis:6379/2"] }
  let(:key) { "test:rate:limit" }
  let(:rate) { 2 } # 2 requests
  let(:interval) { 1 } # per 1 second
  let(:redis) { Redis.new(url: redis_urls.first) }

  subject { described_class.new(redis_urls: redis_urls, key: key, rate: rate, interval: interval) }

  before do
    # Clear any existing locks
    redis.flushdb
  end

  after do
    redis.quit
  end

  describe "#shift" do
    it "allows only specified number of requests within the interval" do
      start_time = Time.now
      execution_times = []

      # Try to make 5 requests when only 2 per second are allowed
      5.times do
        subject.shift do
          execution_times << Time.now - start_time
        end
      end

      # Each request should be at least lock_duration apart (500ms in this case)
      execution_times.each_cons(2) do |t1, t2|
        expect(t2 - t1).to be >= 0.5
      end

      # Total time for 5 requests should be around 2 seconds
      # (2 requests per second = 500ms between requests)
      # Adding more tolerance for system variations and overhead
      total_time = execution_times.last - execution_times.first
      expect(total_time).to be_within(1.0).of(3.0)
    end

    it "works correctly across multiple threads" do
      start_time = Time.now
      execution_times = Queue.new

      threads = 4.times.map do
        Thread.new do
          subject.shift do
            execution_times << Time.now - start_time
          end
        end
      end

      threads.each(&:join)
      times = []
      times << execution_times.pop until execution_times.empty?
      times.sort!

      # Each request should be at least lock_duration apart
      times.each_cons(2) do |t1, t2|
        expect(t2 - t1).to be >= 0.5
      end

      # Total time for 4 requests should be around 1.5 seconds
      # (2 requests per second = 500ms between requests)
      # Adding more tolerance for system variations and overhead
      total_time = times.last - times.first
      expect(total_time).to be_within(0.5).of(1.5)
    end

    it "calculates lock duration correctly" do
      # For 2 requests per second, lock duration should be 500ms
      expect(subject.lock_duration).to eq(500)

      # For 4 requests per second
      queue = described_class.new(redis_urls: redis_urls, key: key, rate: 4, interval: 1)
      expect(queue.lock_duration).to eq(250)
    end
  end
end
