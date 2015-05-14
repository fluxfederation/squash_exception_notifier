require 'spec_helper_rails'

describe Squash::Ruby do
  it do
    #NB: It may never be possible to make this pass, with Squash::Ruby
    #    monkey-patching style
    expect(Squash::Ruby.client_name).to eq('squash-notifier-rails')
  end
end
