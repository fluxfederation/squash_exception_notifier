class ExceptionNotifier::SquashNotifier::SquashRubyNotifier < ExceptionNotifier::SquashNotifier::BaseNotifier
  self.whitelisted_env_vars += [
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

  def call(exception, data={})
    #NB: You can pass a `user_data` hash to #notify, and most attr's will be placed into a `user_data` field
    Squash::Ruby.notify(exception, data)
  end
end
