# frozen_string_literal: true

require "spec_helper"
require "dip/commands/provision"

describe Dip::Commands::Provision, config: true do
  let(:config) { {provision: commands} }

  subject { described_class.new }

  describe "#execute" do
    context "when has no any commands" do
      let(:commands) { [] }
      it { expect { subject.execute }.to_not raise_error }
    end

    context "when has some commands" do
      let(:commands) { ["dip bundle install"] }

      before { subject.execute }

      it { expected_subshell("dip bundle install") }
    end
  end
end
