# frozen_string_literal: true

require "dip/cli"
require "dip/commands/provision"

describe Dip::Commands::Provision, config: true do
  let(:config) { {provision: commands} }
  let(:cli) { Dip::CLI }

  context "when has no any commands" do
    let(:commands) { [] }
    it { expect { cli.start ["provision"] }.to_not raise_error }
  end

  context "when has some commands" do
    let(:commands) { ["dip bundle install"] }

    before { cli.start ["provision"] }

    it { expected_subprocess("dip bundle install", []) }
  end
end
