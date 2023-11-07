# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/run"

describe Dip::Commands::Runners::KubectlRunner, :config do
  let(:config) { {interaction: commands} }
  let(:commands) do
    {
      bash: {pod: "app", command: "/usr/bin/bash"},
      bundle: {runner: "kubectl", pod: "app:cont", command: "bundle"},
      rails: {
        pod: "app",
        entrypoint: "/entrypoint",
        command: "rails"
      },
      psql: {pod: "app", command: "psql -h postgres", default_args: "db_dev"}
    }
  end
  let(:cli) { Dip::CLI }

  context "when run bash command" do
    before { cli.start "run bash".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "/usr/bin/bash"]) }
  end

  context "when run shorthanded bash command" do
    before { cli.start ["bash"] }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "/usr/bin/bash"]) }
  end

  context "when run psql command without db name" do
    before { cli.start "run psql".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "psql", "-h", "postgres", "db_dev"]) }
  end

  context "when run psql command with db name" do
    before { cli.start "run psql db_test".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "psql", "-h", "postgres", "db_test"]) }
  end

  context "when run rails command" do
    before { cli.start "run rails".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "/entrypoint", "rails"]) }
  end

  context "when run rails command with subcommand" do
    before { cli.start "run rails console".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "/entrypoint", "rails", "console"]) }
  end

  context "when run rails command with arguments" do
    before { cli.start "run rails g migration add_index --force".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "app", "--", "/entrypoint", "rails", "g", "migration", "add_index", "--force"]) }
  end

  context "when run with specific container" do
    before { cli.start "bundle".shellsplit }

    it { expected_exec("kubectl", ["exec", "--tty", "--stdin", "--container", "cont", "app", "--", "bundle"]) }
  end

  context "when config with namespace" do
    let(:config) do
      {
        environment: {
          "STAGE" => ""
        },
        kubectl: {
          namespace: "appspace-${STAGE}"
        },
        interaction: commands
      }
    end

    before { cli.start "run rails server".shellsplit }

    it { expected_exec("kubectl", ["--namespace", "appspace", "exec", "--tty", "--stdin", "app", "--", "/entrypoint", "rails", "server"]) }
  end
end
