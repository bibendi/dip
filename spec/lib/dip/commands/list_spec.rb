# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/list"

describe Dip::Commands::List, :config do
  let(:config) { {interaction: commands} }
  let(:commands) do
    {
      bash: {service: "app"},
      rails: {
        service: "app", command: "rails", description: "Run Rails command",
        subcommands: {
          s: {
            description: "Run Rails server",
            service: "web"
          }
        }
      }
    }
  end
  let(:cli) { Dip::CLI }

  before { cli.start "ls".shellsplit }

  it "prints all run commands" do
    expected_output = <<~OUT
      bash     #
      rails    # Run Rails command
      rails s  # Run Rails server
    OUT

    expect { cli.start "ls".shellsplit }.to output(expected_output).to_stdout
  end
end
