# frozen_string_literal: true

require "dip/cli"
require "dip/commands/preflight"

describe Dip::Commands::Preflight, :config do
  let(:config) { {preflight: commands} }
  let(:cli) { Dip::CLI }

  context "when running a dip compose subcommand with no preflight commands" do
    let(:commands) { [] }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", "compose run") }
  end

  context "when running a dip compose subcommand with passing preflight commands" do
    let(:commands) { ["./bin/check-credentials", "test -f .env"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "compose run".shellsplit
    end

    it "runs each preflight command in order" do
      expected_subprocess("./bin/check-credentials", [])
      expected_subprocess("test -f .env", [])
    end

    it { expected_exec("docker", "compose run") }
  end

  context "when a preflight command contains env interpolation", :env do
    let(:commands) { ["echo $RAILS_ENV"] }
    let(:env) { {"RAILS_ENV" => "development"} }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "compose run".shellsplit
    end

    it { expected_subprocess("echo development", []) }
  end
end
