# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/run"

describe Dip::Commands::Run, config: true do
  let(:config) { {interaction: commands} }
  let(:commands) { {bash: {service: "app"}, rails: {service: "app", command: "rails"}} }
  let(:cli) { Dip::CLI }

  context "when run bash command" do
    before { cli.start "run bash".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "app"]) }
  end

  context "when run rails command" do
    before { cli.start "run rails".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "app", "rails"]) }
  end

  context "when run rails command with subcommand" do
    before { cli.start "run rails console".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "app", "rails", "console"]) }
  end

  context "when run rails command with arguments" do
    before { cli.start "run rails g migration add_index --force".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "app", "rails", "g", "migration", "add_index", "--force"]) }
  end

  context "when config with compose_run_options" do
    let(:commands) { {bash: {service: "app", compose_run_options: ["foo", "-bar", "--baz=qux"]}} }
    before { cli.start "run bash".shellsplit }
    it { expected_exec("docker-compose", ["run", "--foo", "-bar", "--baz=qux", "--rm", "app"]) }
  end

  context "when config with compose_method" do
    let(:commands) { {rails: {service: "app", command: "rails", compose_method: "up"}} }
    before { cli.start "run rails server".shellsplit }
    it { expected_exec("docker-compose", ["up", "app", "rails", "server"]) }
  end

  context "when run vars" do
    before { cli.start "FOO=foo run bash".shellsplit }
    it { expected_exec("docker-compose", ["run", "-e", "FOO=foo", "--rm", "app"]) }
  end

  context "when config with environment vars" do
    let(:commands) { {rspec: {service: "app", command: "rspec", environment: {"RAILS_ENV" => "test"}}} }
    before { cli.start "run rspec".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "app", "rspec"], env: hash_including("RAILS_ENV" => "test")) }
  end

  context "when config with subcommands" do
    let(:commands) { {rails: {service: "app", command: "rails", subcommands: subcommands}} }
    let(:subcommands) { {s: {command: "rails server"}} }

    context "and run rails server" do
      before { cli.start "run rails s".shellsplit }
      it { expected_exec("docker-compose", ["run", "--rm", "app", "rails", "server"]) }
    end

    context "when run rails command with other subcommand" do
      before { cli.start "run rails console".shellsplit }
      it { expected_exec("docker-compose", ["run", "--rm", "app", "rails", "console"]) }
    end

    context "when run rails command with arguments" do
      before { cli.start "run rails s foo --bar".shellsplit }
      it { expected_exec("docker-compose", ["run", "--rm", "app", "rails", "server", "foo", "--bar"]) }
    end

    context "when config with compose_run_options" do
      let(:subcommands) { {s: {command: "rails s", compose_run_options: ["foo", "-bar", "--baz=qux"]}} }
      before { cli.start "run rails s".shellsplit }
      it { expected_exec("docker-compose", ["run", "--foo", "-bar", "--baz=qux", "--rm", "app", "rails", "s"]) }
    end

    context "when config with compose_method" do
      let(:subcommands) { {s: {service: "web", compose_method: "up"}} }
      before { cli.start "run rails s".shellsplit }
      it { expected_exec("docker-compose", ["up", "web"]) }
    end

    context "when config with environment vars" do
      let(:subcommands) do
        {"refresh-test-db": {command: "rake db:drop db:tests:prepare db:migrate",
                             environment: {"RAILS_ENV" => "test"}}}
      end

      before { cli.start "run rails refresh-test-db".shellsplit }

      it do
        expected_exec("docker-compose",
                      ["run", "--rm", "app", "rake", "db:drop", "db:tests:prepare", "db:migrate"],
                      env: hash_including("RAILS_ENV" => "test"))
      end
    end
  end
end
