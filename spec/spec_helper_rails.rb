require 'rails'
require 'spec_helper'

RSpec.shared_context "rails" do
  let(:rails) do
    class_double("Rails").
      as_stubbed_const(:transfer_nested_constants => true)
  end
end
