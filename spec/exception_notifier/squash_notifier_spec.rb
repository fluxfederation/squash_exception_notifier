require 'spec_helper'

RSpec.shared_context "squash_ruby" do
  let(:squash_ruby) do
    class_double("Squash::Ruby").
      as_stubbed_const(:transfer_nested_constants => true)
  end
end

describe ExceptionNotifier::SquashNotifier do
  include_context "squash_ruby"

  let(:squash_notifier) { ExceptionNotifier.registered_exception_notifier(:squash) }

  describe "with a valid instance" do
    before(:context) do
      @squash_config_options = {
        api_host: 'https://no-such-host.noncom',
        api_key: '00000000-0000-0000-0000-000000000000',
        environment: 'development'
      }

      env = ExceptionNotifier::SquashNotifier.whitelisted_env_vars.map do |k|
        k = k.to_s.sub(/^(\(.*:)(.*)(\))$/, '\2') if k.is_a? Regexp
        [k.to_s, "val #{k}"]
      end
      @captured_env_vars = Hash[env]
    end

    describe "created directly" do
      it "can create a SquashNotifier from a const" do
        expect(squash_ruby).to receive(:configure).with(
          @squash_config_options.merge(disabled: false, filter_env_vars: duck_type(:call))
        )
        expect(ExceptionNotifier::SquashNotifier.new(@squash_config_options)).to be_an ExceptionNotifier::SquashNotifier
      end

    end

    describe "created via ExceptionNotifier" do
      around(:context) do |eg|
        ExceptionNotification.configure {|c| c.add_notifier :squash, @squash_config_options }
        eg.run
        ExceptionNotification.configure {|c| c.unregister_exception_notifier :squash }
      end
      let(:squash_notifier) { ExceptionNotifier.registered_exception_notifier(:squash) }

      #Time.stubs(:current).returns('Sat, 20 Apr 2013 20:58:55 UTC +00:00')

      it "has a version number" do
        expect(ExceptionNotifier::SquashNotifier::VERSION).not_to be_nil
      end

      it "notifies Squash of an exception" do
        begin
          1/0
        rescue => e
          expect(squash_ruby).to receive(:notify).with(e, {})
          ExceptionNotifier.notify_exception(e, {})
        end
      end

      context "whitelisting" do
        it "should be the same at class and instance level" do
          #NB: Need to use #class_eval, as the underlying is dynamically extended
          expect(squash_notifier.whitelisted_env_vars).to eq(ExceptionNotifier::SquashNotifier.class_eval { self.whitelisted_env_vars })
        end

        context "with faked ENV" do
          around do |eg|
            ENV["NOSUCHVAR"] = "Test"
            eg.run
            ENV.delete("NOSUCHVAR")
          end

          it do
            expect(Squash::Ruby.class_eval { environment_data['env_vars'] }).to include("HOME" => String)
          end

          it do
            expect(Squash::Ruby.class_eval { environment_data['env_vars'] }).not_to include("NOSUCHVAR" => "Test")
          end
        end
      end

      context "for Rails env" do
        context "when Rails.env is set" do
          let(:rails_rails_env) { class_double("Rails").as_stubbed_const(:transfer_nested_constants => true) }

          around(:all) do |eg|
            class Rails
              def self.env; true; end
            end
            eg.run
            Object.send(:remove_const, :Rails)
          end

          it do
            expect(rails_rails_env).to receive(:env).with(no_args).and_return("Rails.env set")
            expect(ExceptionNotifier::SquashNotifier.rails_env).to eq("Rails.env set")
          end
        end

        context "when ENV['RAILS_ENV'] is set" do
          around(:all) do |eg|
            ENV["RAILS_ENV"] = "RAILS_ENV set"
            eg.run
            ENV.delete("RAILS_ENV")
          end

          it do
            expect(ExceptionNotifier::SquashNotifier.rails_env).to eq("RAILS_ENV set")
          end
        end

        context "when ENV['RACK_ENV'] is set" do
          around(:all) do |eg|
            ENV["RACK_ENV"] = "RACK_ENV set"
            eg.run
            ENV.delete("RACK_ENV")
          end

          it do
            expect(ExceptionNotifier::SquashNotifier.rails_env).to eq("RACK_ENV set")
          end
        end
      end
    end
  end

  describe "with Squash unregistered" do
    it "should note find a Squash notifier" do
      expect(squash_notifier).to be_nil
    end
  end
end
