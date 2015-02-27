require "exception_notifier/squash_notifier/version"

require "active_support/core_ext/module/attribute_accessors"
require "exception_notifier"
require "squash/ruby"

module ExceptionNotifier
  class SquashNotifier ##<Struct.new()
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
      { api_host: "localhost",
        environment: self.rails_env }
    end

    def self.rails_env
      #TODO(willjr): I don't believe I have to check `defined? Rails`
      if defined? Rails.env
        Rails.env
      else
        ENV['RAILS_ENV'] || ENV['RACK_ENV']
      end
    end

    def initialize(options)
      Squash::Ruby.configure default_options(options)
      #super(*options.reverse_merge(self.class.default_options).values_at())
    end

    def options
      @options ||= {}.tap do |opts|
        each_pair { |k,v| opts[k] = v }
      end
    end

    def call(exception, options={})
      #NB: You can pass a `user_data` hash to #notify, and most attr's will be placed into a `user_data` field
      Squash::Ruby.notify(exception, options)
      #create_email(exception, options).deliver
    end

    protected

    def default_options(options)
      # We want to add a `disabled` key if no `api_key` is provided:
      self.class.default_options.merge(disabled: !options[:api_key]).merge(options)
    end

    private

    # Remove any entries from the 'env' var that are not in the 'whitelisted_env_var' list
    def whitelist_env(env)
      env.select do |key, val|
        whitelisted_env_vars.any? {|allowed| (allowed.is_a? Regexp) ? key =~ allowed : key == allowed }
      end
    end
  end
end
