require "exception_notifier/squash_notifier/version"

require "active_support/core_ext/module/attribute_accessors"
require "exception_notifier"

require "exception_notifier/squash_ruby"

module ExceptionNotifier
  class SquashNotifier
    @@whitelisted_env_vars = [
      'action_dispatch.request.parameters',
      'action_dispatch.request.path_parameters',
      'action_dispatch.request.query_parameters',
      'action_dispatch.request.request_parameters',
      'BUNDLE_BIN_PATH',
      'BUNDLE_GEMFILE',
      'CONTENT_LENGTH',
      'CONTENT_TYPE',
      'DOCUMENT_ROOT',
      'GEM_HOME',
      'HOME',
      /HTTP_/,
      'ORIGINAL_FULLPATH',
      'PASSENGER_APP_TYPE',
      'PASSENGER_ENV',
      'PASSENGER_RUBY',
      'PASSENGER_SPAWN_METHOD',
      'PASSENGER_USER',
      'PATH',
      'PATH_INFO',
      'PWD',
      'RAILS_ENV',
      'REMOTE_ADDR',
      'REMOTE_PORT',
      'REQUEST_METHOD',
      'REQUEST_URI',
      'RUBYOPT',
      'SERVER_ADDR',
      'SERVER_NAME',
      'SERVER_PORT',
      'SERVER_PROTOCOL',
      'SERVER_SOFTWARE',
      'TMPDIR',
      'USER',
    ]
    cattr_accessor :whitelisted_env_vars

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
          # self.whitelisted_env_vars.any? {|allowed| (allowed.is_a? Regexp) ? key =~ allowed : key == allowed }
        end
      end
    end

    #####

    def initialize(options)
      Squash::Ruby.configure default_options.merge(options)
      Squash::Ruby.configure disabled: !Squash::Ruby.configuration(:api_key)
      #super(*options.reverse_merge(self.class.default_options).values_at())
    end

    def call(exception, options={})
      #NB: You can pass a `user_data` hash to #notify, and most attr's will be placed into a `user_data` field
      Squash::Ruby.notify(exception, options)
    end
  end
end
