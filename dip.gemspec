# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "dip/version"

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = "dip"
  spec.license       = "MIT"
  spec.version       = Dip::VERSION
  spec.authors       = ["bibendi"]
  spec.email         = ["merkushin.m.s@gmail.com"]

  spec.summary       = "Ruby gem CLI tool for better interacting docker-compose files."
  spec.description   = "DIP - Docker Interaction Process." \
                       "CLI tool for better development experience when interacting with docker and docker-compose."
  spec.homepage      = "https://github.com/bibendi/dip"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.glob('lib/**/*') + Dir.glob('exe/*') + %w(LICENSE.txt README.md)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4'

  spec.add_dependency "thor", ">= 0.20", "< 1.1"

  spec.add_development_dependency "bundler", ">= 1.15"
  spec.add_development_dependency "pry-byebug", "~> 3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.6"
  spec.add_development_dependency "simplecov", '~> 0.16'
  spec.add_development_dependency "test-unit", "~> 3"
end
# rubocop:enable Metrics/BlockLength
