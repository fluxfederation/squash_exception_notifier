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

      it "should have the same whitelist at class and instance level" do
        #NB: Need to use #class_eval, as the underlying is dynamically extended
        expect(squash_notifier.whitelisted_env_vars).to eq(ExceptionNotifier::SquashNotifier.class_eval { self.whitelisted_env_vars })
      end

      it "notifies Squash of an exception" do
        begin
          1/0
        rescue => e
          expect(squash_ruby).to receive(:notify).with(e, {})
          ExceptionNotifier.notify_exception(e, {})
        end
      end
    end
  end

  describe "with Squash unregistered" do
    it "can't find a Squash notifier" do
      expect(squash_notifier).to be_nil
    end
  end
end


=begin
require 'test_helper'

class EmailNotifierWhitespaceTest < ActiveSupport::TestCase
setup do
Time.stubs(:current).returns('Sat, 20 Apr 2013 20:58:55 UTC +00:00')
@email_notifier = ExceptionNotifier.registered_exception_notifier(:email)
@captured_env_vars = Hash[@email_notifier.mailer.whitelisted_env_vars.map do |k|
k = k.to_s.sub(/^(\(.*:)(.*)(\))$/, '\2') if k.is_a? Regexp
[k.to_s, "val #{k}"]
end]

begin
1/0
rescue => e
@exception = e
@mail1 = @email_notifier.create_email(@exception,
:sections => %w(environment),
:env => @captured_env_vars.dup)
@mail2 = @email_notifier.create_email(@exception,
:sections => %w(environment),
:env => {"NOHOME" => "woot"})
end
end

test "should have the same whitelist at class and instance level" do
#NB: Need to use #class_eval, as the underlying is dynamically extended
assert @email_notifier.mailer.whitelisted_env_vars == @email_notifier.mailer.class_eval { self.whitelisted_env_vars }
end

test "should keep whitelisted env-vars" do
@captured_env_vars.each do |k, v|
assert @mail1.body =~ /\*\s*#{k}\s*:\s*#{v}$/, "Could not find #{k.inspect}: #{v.inspect} in the mail.body"
end
end

test "should drop the non-whitelisted env-vars" do
assert @mail1.body !~ /NOHOME:/
end
end
=end
