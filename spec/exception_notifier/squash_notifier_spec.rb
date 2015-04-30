require 'spec_helper'

RSpec.shared_context "squash_ruby" do
  let(:squash_ruby) do
    class_double("Squash::Ruby").
      as_stubbed_const(:transfer_nested_constants => true)
  end
end

RSpec.shared_context "squash_notifier" do
  before(:context) do
    @squash_config_options = {
      api_host: 'https://no-such-host.noncom',
      api_key: '00000000-0000-0000-0000-000000000000',
      environment: 'development'
    }

    env = described_class.whitelisted_env_vars.map do |k|
      k = k.to_s.sub(/^(\(.*:)(.*)(\))$/, '\2') if k.is_a? Regexp
      [k.to_s, "val #{k}"]
    end
    @captured_env_vars = Hash[env]
  end

  describe "created directly" do
    it "can create a #{described_class} from a const" do
      expect(squash_ruby).to receive(:configure).with(
        @squash_config_options.merge(filter_env_vars: duck_type(:call))
      )
      expect(squash_ruby).to receive(:configuration).with(:api_key).and_return(true)
      expect(squash_ruby).to receive(:configure).with(disabled: false)
      expect(ExceptionNotifier::SquashNotifier.new(@squash_config_options)).to be_an described_class
    end
  end
end

describe ExceptionNotifier::SquashNotifier::SquashRubyNotifier do
  include_context "squash_ruby"

  around(:context) do |eg|
    saved = ExceptionNotifier::SquashNotifier.enable_rails
    ExceptionNotifier::SquashNotifier.enable_rails = false

    eg.run

    ExceptionNotifier::SquashNotifier.enable_rails = saved
  end

  let(:squash_notifier) { ExceptionNotifier.registered_exception_notifier(:squash) }

  describe "with a valid instance" do
    include_context "squash_notifier"

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
          expect(squash_notifier.whitelisted_env_vars).to eq(ExceptionNotifier::SquashNotifier::SquashRubyNotifier.class_eval { self.whitelisted_env_vars })
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
    end
  end

  describe "with Squash unregistered" do
    it "should note find a Squash notifier" do
      expect(squash_notifier).to be_nil
    end
  end
end

#####

describe ExceptionNotifier::SquashNotifier::SquashRailsNotifier do
  include_context "squash_ruby"

  describe "with a valid instance" do
    include_context "squash_notifier"
  end
end
