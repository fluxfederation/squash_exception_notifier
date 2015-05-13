require 'spec_helper'

describe Squash::Ruby do
  it do
    pending("monkey-patching makes me sad")
    #NB: It may never be possible to make this pass, with Squash::Ruby
    #    monkey-patching style
    expect(Squash::Ruby.client_name).to eq('squash-notifier')
  end

  describe "with a valid instance" do
    context "with a key-replacement env-var filter" do
      around(:all) do |eg|
        @key_prefix = '@@ '
        @val_prefix = '== '
        filter_env_vars = lambda do |env_vars|
          Hash[env_vars.map {|h, v| [@key_prefix + h.to_s, @val_prefix + v.to_s] }]
        end

        Squash::Ruby.configure(filter_env_vars: filter_env_vars)
        eg.run
        Squash::Ruby.configure(filter_env_vars: nil)
      end

      it "should return prefaced keys and val's for ENV" do
        Squash::Ruby.class_eval { environment_data['env_vars'] }.each do |k, v|
          expect(k).to match(/^#{@key_prefix}/),
            "expected ENV[#{k}].key to start with #{@key_prefix.inspect}"
          expect(v).to match(/^#{@val_prefix}/),
            "expected ENV[#{k}].val to start with #{@val_prefix.inspect}"
        end
      end
    end
  end
end
