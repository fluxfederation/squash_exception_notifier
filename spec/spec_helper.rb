require 'simplecov'
SimpleCov.start do
  add_filter "/.bundle/"
end

#####

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'exception_notification'
require 'exception_notifier/squash_notifier'
