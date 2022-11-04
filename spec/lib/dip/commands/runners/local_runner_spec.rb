# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/run"

describe Dip::Commands::Runners::LocalRunner, config: true do
  let(:config) { {interaction: commands} }
  let(:commands) do
    {
      setup: {command: "./bin/setup", default_args: "all"}
    }
  end
  let(:cli) { Dip::CLI }

  context "when using default args" do
    before { cli.start "run setup".shellsplit }

    it { expected_exec("./bin/setup", ["all"]) }
  end

  context "when args are provided" do
    before { cli.start "run setup db".shellsplit }

    it { expected_exec("./bin/setup", ["db"]) }
  end
end
