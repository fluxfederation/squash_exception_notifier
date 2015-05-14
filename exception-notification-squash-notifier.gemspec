# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_notifier/squash_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "exception_notification-squash_notifier"
  spec.version       = ExceptionNotifier::SquashNotifier::VERSION
  spec.authors       = ["Will Robertson"]
  spec.email         = ["will.robertson@powershop.co.nz"]
  spec.summary       = %q{Exception Notifier plugin for Squash}
  spec.description   = %q{Plugin to use Squash with ExceptionNotification}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry-byebug", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.9"
  spec.add_development_dependency "exception_notification", "~> 4.0"

  spec.add_development_dependency "rails", ">= 3.0"

  spec.add_dependency "activesupport", ">= 3.0"
  spec.add_dependency "squash_ruby", "~> 2.0"
end
