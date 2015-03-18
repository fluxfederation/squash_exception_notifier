require 'simplecov'
SimpleCov.start

#####

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'exception_notification'
require 'exception_notifier/squash_notifier'
