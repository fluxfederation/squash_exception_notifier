module ExceptionNotifier
  class SquashNotifier
    # Factory class:
    def self.new(*args, &p)
      return SquashRailsNotifier.new(*args, &p) if defined? Rails
      SquashRubyNotifier.new(*args, &p)
    end

    class BaseNotifier
      cattr_accessor :whitelisted_env_vars
      # This accepts RegEx, so to not-whitelist, add an entry of /.*/
      self.whitelisted_env_vars = []

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
        raise NotImplementedError
      end
    end
  end
end
