# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notifier/squash/version'

Gem::Specification.new do |spec|
  spec.name          = "exception-notification-squash"
  spec.version       = ExceptionNotifier::Squash::VERSION
  spec.authors       = ["Will Robertson"]
  spec.email         = ["will.robertson@powershop.co.nz"]
  spec.summary       = %q{Exception Notifier plugin for Squash}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry-byebug"

  spec.add_runtime_dependency "squash_ruby"
end