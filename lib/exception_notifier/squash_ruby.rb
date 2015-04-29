require "squash/ruby"

module Squash::Ruby

  # You need to set a configuration :filter_env_vars and :filter_argv
  # These are supposed to contain lambdas/procs that will filter the contents of these arrays before sending them up to the Squash server

  class << self
    private

    def client_name
      'squash'
    end

    alias :environment_data__original :environment_data

    def environment_data
      no_filtering = lambda {|val| val }
      filter_env_vars = configuration(:filter_env_vars) || no_filtering
      filter_argv = configuration(:filter_argv) || no_filtering

      ev_orig = environment_data__original
      ev_orig.merge({
        'env_vars' => filter_env_vars.call(ev_orig['env_vars']),  # The original "valueifies" ENV for us
        'arguments' => filter_argv.call(ARGV).join(' ')  # The original munges into a string, which is less-easy to filter
      })
    end
  end
end

# Extend class if you find Rails is being used:
require 'exception_notifier/squash_ruby/rails'  if defined? Rails
