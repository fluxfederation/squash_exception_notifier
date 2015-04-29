# Extend SquashNotifier with Rails support

module Squash::Ruby
  TOP_LEVEL_USER_DATA.concat(
    %w[environment root xhr
       headers
       request_method schema host port path query
       params session flash cookies]
  )

  def self.client_name
    'squash-rails'
  end

  def self.failsafe_log(tag, message)
    logger = Rails.respond_to?(:logger) ? Rails.logger : RAILS_DEFAULT_LOGGER
    if (logger.respond_to?(:tagged))
      logger.tagged(tag) { logger.error message }
    else
      logger.error "[#{tag}]\t#{message}"
    end
  rescue Object => err
    $stderr.puts "Couldn't write to failsafe log (#{err.to_s}); writing to stderr instead."
    $stderr.puts "#{Time.now.to_s}\t[#{tag}]\t#{message}"
  end
end
