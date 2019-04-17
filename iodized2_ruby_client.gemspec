lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "iodized2_ruby_client/version"

Gem::Specification.new do |spec|
  spec.name          = "iodized2_ruby_client"
  spec.version       = Iodized2RubyClient::VERSION
  spec.authors       = ["Julian Doherty (madlep)"]
  spec.email         = ["madlep@madlep.com"]

  spec.summary       = %q{Ruby client for Iodized}
  spec.description   = %q{iodine rich feature toggling}
  spec.homepage      = "https://github.com/envato/iodized2_ruby_client"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "websocket-driver"
  spec.add_dependency "faye-websocket"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
