# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/down_all"

describe Dip::Commands::DownAll do
  let(:cli) { Dip::CLI }

  before { cli.start "down -A".shellsplit }

  it "runs a valid command" do
    expected_subprocess(
      "docker rm --volumes $(docker stop $(docker ps --filter 'label=com.docker.compose.project' -q))",
      []
    )
  end
end
