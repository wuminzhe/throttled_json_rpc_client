# frozen_string_literal: true

require_relative "lib/throttled_json_rpc_client/version"

Gem::Specification.new do |spec|
  spec.name = "throttled_json_rpc_client"
  spec.version = ThrottledJsonRpcClient::VERSION
  spec.authors = ["Aki Wu"]
  spec.email = ["wuminzhe@gmail.com"]

  spec.summary = "throttled_json_rpc_client"
  spec.description = "throttled_json_rpc_client"
  spec.homepage = "https://github.com/wuminzhe/throttled_json_rpc_client"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "redlock"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
