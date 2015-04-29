require "exception_notifier/squash_notifier/version"

require "active_support/core_ext/module/attribute_accessors"
require "exception_notifier"

require "exception_notifier/squash_ruby"

module ExceptionNotifier
  class SquashNotifier
    cattr_accessor :whitelisted_env_vars
    # This accepts RegEx, so to not-whitelist, add an entry of /.*/
    self.whitelisted_env_vars = [
      'BUNDLE_BIN_PATH',
      'BUNDLE_GEMFILE',
      'CONTENT_LENGTH',
      'CONTENT_TYPE',
      'DOCUMENT_ROOT',
      'GEM_HOME',
      'HOME',
      'ORIGINAL_FULLPATH',
      'PATH',
      'PATH_INFO',
      'PWD',
      'RUBYOPT',
      'TMPDIR',
      'USER',
    ]

    def self.default_options
      {
        filter_env_vars: self.whitelist_env_filter
      }
    end

    def default_options
      self.class.default_options
    end

    def self.whitelist_env_filter
      # Remove any entries from the 'env' var that are not in the 'whitelisted_env_var' list
      lambda do |env|
        env.select do |key, val|
          #NB: we want to close-over `self` so we can access the class var
          #NB:
          # - When `allowed` is a Regexp, === is like ((a =~ b) ? true : false)
          # - When `allowed` is a String, === is like (a == b.to_str)
          # - When `allowed` is a Symbol, === is (a == b)
          self.whitelisted_env_vars.any? {|allowed|  allowed === key }
        end
      end
    end

    #####

    def initialize(options)
      Squash::Ruby.configure default_options.merge(options)
      Squash::Ruby.configure disabled: !Squash::Ruby.configuration(:api_key)
    end

    def call(exception, data={})
      #NB: You can pass a `user_data` hash to #notify, and most attr's will be placed into a `user_data` field
      Squash::Ruby.notify(exception, munge_env(data))
    end

    def munge_env(data)
      data
    end
  end
end

# Extend class if you find Rails is being used:
require 'exception_notifier/squash_notifier/rails'  if defined? Rails
