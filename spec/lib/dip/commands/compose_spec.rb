# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/compose"

describe Dip::Commands::Compose do
  let(:cli) { Dip::CLI }

  context "when execute without extra arguments" do
    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", "compose run") }
  end

  context "when execute with arguments" do
    before { cli.start "compose run --rm bash".shellsplit }

    it { expected_exec("docker", ["compose run", "--rm", "bash"]) }
  end

  context "when config contains project_name", :config do
    let(:config) { {compose: {project_name: "rocket"}} }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", ["compose --project-name", "rocket", "run"]) }
  end

  context "when config contains project_name with env vars", :config, :env do
    let(:config) { {compose: {project_name: "rocket-$RAILS_ENV"}} }
    let(:env) { {"RAILS_ENV" => "test"} }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", ["compose --project-name", "rocket-test", "run"]) }
  end

  context "when config contains project_directory", :config do
    let(:config) { {compose: {project_directory: "/foo/bar"}} }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", ["compose --project-directory", "/foo/bar", "run"]) }
  end

  context "when config contains project_directory with env vars", :config, :env do
    let(:config) { {compose: {project_directory: "/foo-$RAILS_ENV"}} }
    let(:env) { {"RAILS_ENV" => "test"} }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", ["compose --project-directory", "/foo-test", "run"]) }
  end

  context "when compose's config path contains spaces", :config do
    let(:config) { {compose: {files: ["file name.yml"]}} }
    let(:file) { fixture_path("empty", "file name.yml") }

    before do
      allow_any_instance_of(Pathname).to receive(:exist?) do |obj|
        case obj.to_s
        when file
          true
        else
          File.exist?(obj.to_s)
        end
      end

      cli.start "compose run".shellsplit
    end

    it { expected_exec("docker", ["compose --file", Shellwords.escape(file), "run"]) }
  end

  context "when config contains multiple docker-compose files", :config do
    context "and some files are not exist" do
      let(:config) { {compose: {files: %w[file1.yml file2.yml file3.yml]}} }
      let(:global_file) { fixture_path("empty", "file1.yml") }
      let(:local_file) { fixture_path("empty", "file2.yml") }
      let(:override_file) { fixture_path("empty", "file3.yml") }

      before do
        allow_any_instance_of(Pathname).to receive(:exist?) do |obj|
          case obj.to_s
          when global_file, override_file
            true
          when local_file
            false
          else
            File.exist?(obj.to_s)
          end
        end

        cli.start "compose run".shellsplit
      end

      it { expected_exec("docker", ["compose --file", global_file, "--file", override_file, "run"]) }
    end

    context "and a file name contains env var", :env do
      let(:config) { {compose: {files: %w[file1-${DIP_OS}.yml]}} }
      let(:file) { fixture_path("empty", "file1-darwin.yml") }
      let(:env) { {"DIP_OS" => "darwin"} }

      before do
        allow_any_instance_of(Pathname).to receive(:exist?) do |obj|
          case obj.to_s
          when file
            true
          else
            File.exist?(obj.to_s)
          end
        end

        cli.start "compose run".shellsplit
      end

      it { expected_exec("docker", ["compose --file", file, "run"]) }
    end
  end

  context "when compose command specified in config", :config do
    context "when compose command contains spaces" do
      let(:config) { {compose: {command: "foo compose"}} }

      before { cli.start "compose run".shellsplit }

      it { expected_exec("foo compose", "run") }
    end

    context "when compose command does not contain spaces" do
      let(:config) { {compose: {command: "foo-compose"}} }

      before { cli.start "compose run".shellsplit }

      it { expected_exec("foo-compose", "run") }
    end
  end

  context "when DIP_COMPOSE_COMMAND is specified in environment", :env do
    context "when DIP_COMPOSE_COMMAND contains spaces" do
      let(:env) { {"DIP_COMPOSE_COMMAND" => "foo compose"} }

      before { cli.start "compose run".shellsplit }

      it { expected_exec("foo compose", "run") }
    end

    context "when DIP_COMPOSE_COMMAND does not contain spaces" do
      let(:env) { {"DIP_COMPOSE_COMMAND" => "foo-compose"} }

      before { cli.start "compose run".shellsplit }

      it { expected_exec("foo-compose", "run") }
    end

    context "when compose command specified in config", :config do
      let(:config) { {compose: {command: "foo compose"}} }
      let(:env) { {"DIP_COMPOSE_COMMAND" => "bar-compose"} }

      before { cli.start "compose run".shellsplit }

      it { expected_exec("bar-compose", "run") }
    end
  end
end
