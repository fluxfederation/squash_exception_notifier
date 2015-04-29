# Extend SquashNotifier with Rails support

require 'pp'

class ExceptionNotifier::SquashNotifier
  self.whitelisted_env_vars += [
    'action_dispatch.request.parameters',
    'action_dispatch.request.path_parameters',
    'action_dispatch.request.query_parameters',
    'action_dispatch.request.request_parameters',
    /HTTP_/,
    'PASSENGER_APP_TYPE',
    'PASSENGER_ENV',
    'PASSENGER_RUBY',
    'PASSENGER_SPAWN_METHOD',
    'PASSENGER_USER',
    'RAILS_ENV',
    'REMOTE_ADDR',
    'REMOTE_PORT',
    'REQUEST_METHOD',
    'REQUEST_URI',
    'SERVER_ADDR',
    'SERVER_NAME',
    'SERVER_PORT',
    'SERVER_PROTOCOL',
    'SERVER_SOFTWARE',
  ]

  def munge_env(data)
    return data unless data.has_key?(:env)

    env = data.delete(:env)

    request = ActionDispatch::Request.new(env)

    whitelist_env = Squash::Ruby.configuration(:filter_env_vars)
    parameter_filter = ActionDispatch::Http::ParameterFilter.new(env["action_dispatch.parameter_filter"])
    filtered_env = whitelist_env.call(request.try(:filtered_env) || parameter_filter.filter(env))

    data.merge(occurence_data(
      request: request,
      session: parameter_filter.filter(request.session.to_hash),
      # cookies: env['rack.request.cookie_hash'],
      rack_env: filtered_env
    ))
  end

  private

  def occurence_data(request: nil, session: nil, rack_env: {})
    #TODO: Remove when done:
    # flash_key = defined?(ActionDispatch) ? ActionDispatch::Flash::KEY : 'flash'

    # raw_session_id = request.session['session_id'] || (request.env["rack.session.options"] and request.env["rack.session.options"][:id])
    # session_id = request.ssl? ? "[FILTERED]" : raw_session_id.inspect

    PP.pp session, session_s=""

    #NB: If you update this hash, make sure to update TOP_LEVEL_USER_DATA in
    #    squash_ruby/rails.rb
    {
      :environment    => environment_name,
      :root           => root_path,

      # Squash Server recreates the URL from these:
      :request_method => request.request_method.to_s,
      :schema         => request.protocol.sub('://', ''),
      :host           => request.host,
      :port           => request.port,
      :path           => request.path,
      :query          => request.query_string,
      :headers        => request_headers(rack_env),

      # :controller  ## Rails Controller
      # :action  ## Rails Action
      :params         => request.filtered_parameters,
      :session        => session,
      # :flash          => session[flash_key],
      # :cookies        => cookies,

      # User Data:
      :host_ip        => request.remote_ip,
      :host_name      => Socket.gethostname,
      :"rack.env"     => rack_env.to_hash,
      :"session.to_s" => session_s
    }
  end

  def environment_name
    return ::Rails.env.to_s if defined?(::Rails)
    ENV['RAILS_ENV'] || ENV['RACK_ENV']
  end

  # Extract any rack key/value pairs where the key begins with HTTP_*
  def request_headers(env)
    env.select { |key, _| key[0, 5] == 'HTTP_' }
  end

  def root_path
    defined?(::Rails) ? ::Rails.root.to_s : ENV['RAILS_ROOT']
  end
end
