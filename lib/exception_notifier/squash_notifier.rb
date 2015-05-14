require "exception_notifier/squash_notifier/version"

require "active_support/core_ext/module/attribute_accessors"
require "exception_notifier"

require "exception_notifier/squash_ruby/ruby"
# Extend class if you find Rails is being used:
require 'exception_notifier/squash_ruby/rails'  if defined? Rails

require 'exception_notifier/squash_notifier/base'
require 'exception_notifier/squash_notifier/ruby'
require 'exception_notifier/squash_notifier/rails'
