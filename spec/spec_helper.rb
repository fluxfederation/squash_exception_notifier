require 'simplecov'
SimpleCov.start do
  add_filter "/.bundle/"
end

require 'pry'

#####

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'exception_notification'
require 'exception_notifier/squash_notifier'

RSpec.shared_context "squash_ruby" do
  let(:squash_ruby) do
    class_double("Squash::Ruby").
      as_stubbed_const(:transfer_nested_constants => true)
  end
end
