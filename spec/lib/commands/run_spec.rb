require 'dip/commands/run'

describe Dip::Commands::Run, config: true do
  let(:config) { {interaction: commands} }
  let(:commands) { {bash: {service: "app"}, rails: {service: "app", command: "rails"}} }

  let(:cmd) { nil }
  let(:subcmd) { nil }
  let(:argv) { [] }
  let(:options) { {} }

  subject { described_class.new(cmd, subcmd, argv, **options) }

  describe "#execute" do
    before { subject.execute }

    context "when run bash command" do
      let(:cmd) { "bash" }
      it { expected_exec("docker-compose", "run", "--rm", "app") }
    end

    context "when run rails command" do
      let(:cmd) { "rails" }
      it { expected_exec("docker-compose", "run", "--rm", "app", "rails") }
    end

    context "when run rails command with subcommand" do
      let(:cmd) { "rails" }
      let(:subcmd) { "console" }
      it { expected_exec("docker-compose", "run", "--rm", "app", "rails", "console") }
    end

    context "when run rails command with arguments" do
      let(:cmd) { "rails" }
      let(:subcmd) { "g" }
      let(:argv) { %w(migration add_index --force) }
      it { expected_exec("docker-compose", "run", "--rm", "app", "rails", "g", "migration", "add_index", "--force") }
    end

    context "when config with compose_run_options" do
      let(:cmd) { "bash" }
      let(:commands) { {bash: {service: "app", compose_run_options: ["foo", "-bar", "--baz=qux"]}} }
      it { expected_exec("docker-compose", "run", "--foo", "-bar", "--baz=qux", "--rm", "app") }
    end

    context "when config with compose_method" do
      let(:cmd) { "rails" }
      let(:subcmd) { "server" }
      let(:commands) { {rails: {service: "app", command: "rails", compose_method: "up"}} }
      it { expected_exec("docker-compose", "up", "app", "rails", "server") }
    end

    context "when run vars" do
      let(:cmd) { "bash" }
      let(:options) { {run_vars: {"FOO" => "bar"}} }
      it { expected_exec("docker-compose", "run", "-e", "FOO=bar", "--rm", "app") }
    end

    context "when config with environment vars" do
      let(:cmd) { "rspec" }
      let(:commands) { {rspec: {service: "app", command: "rspec", environment: {"RAILS_ENV" => "test"}}} }

      it { expected_exec("docker-compose", "run", "--rm", "app", "rspec", env: {"RAILS_ENV" => "test"}) }
    end

    context "when config with subcommands" do
      let(:cmd) { "rails" }
      let(:subcmd) { "s" }
      let(:commands) { {rails: {service: "app", command: "rails", subcommands: subcommands}} }
      let(:subcommands) { {s: {command: "rails server"}} }

      context "and run rails server" do
        it { expected_exec("docker-compose", "run", "--rm", "app", "rails", "server") }
      end

      context "when run rails command with other subcommand" do
        let(:subcmd) { "console" }
        it { expected_exec("docker-compose", "run", "--rm", "app", "rails", "console") }
      end

      context "when run rails command with arguments" do
        let(:argv) { %w(foo --bar) }
        it { expected_exec("docker-compose", "run", "--rm", "app", "rails", "server", "foo", "--bar") }
      end

      context "when config with compose_run_options" do
        let(:subcommands) { {s: {command: "rails s", compose_run_options: ["foo", "-bar", "--baz=qux"]}} }
        it { expected_exec("docker-compose", "run", "--foo", "-bar", "--baz=qux", "--rm", "app", "rails", "s") }
      end

      context "when config with compose_method" do
        let(:subcommands) { {s: {service: "web", compose_method: "up"}} }
        it { expected_exec("docker-compose", "up", "web") }
      end

      context "when config with environment vars" do
        let(:subcmd) { "retest" }
        let(:subcommands) do
          {retest: {command: "rake db:drop db:tests:prepare db:migrate", environment: {"RAILS_ENV" => "test"}}}
        end

        it do
          expected_exec("docker-compose", "run", "--rm", "app",
                        "rake", "db:drop", "db:tests:prepare", "db:migrate",
                        env: {"RAILS_ENV" => "test"})
        end
      end
    end
  end
end
