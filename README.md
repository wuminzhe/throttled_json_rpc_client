# ThrottledJsonRpcClient

Use the way from this [article](https://medium.com/@jaimersonn/throttling-api-calls-in-a-distributed-environment-76d2789a796d).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add throttled_json_rpc_client

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install throttled_json_rpc_client

## Usage

This rate throttling can be used in multi-threaded, multi-process, multi-machine environments.

```ruby
rpc_url = "https://eth.llamarpc.com"

# default equals to ThrottledJsonRpcClient::Eth.new(url, rate: 5, interval: 1, redis_urls: ["redis://localhost:6379/2"])
client = ThrottledJsonRpcClient::Client.new(rpc_url)

threads = []
10.times do
  threads << Thread.new do
    p client.call("eth_getBlockByNumber", ["0x1234", false])
  end
end
threads.map(&:join)
```
see [example](./example.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wuminzhe/throttled_json_rpc_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/wuminzhe/throttled_json_rpc_client/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ThrottledJsonRpcClient project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/wuminzhe/throttled_json_rpc_client/blob/main/CODE_OF_CONDUCT.md).
