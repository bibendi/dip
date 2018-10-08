# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/compose"

describe Dip::Commands::Compose do
  let(:cli) { Dip::CLI }

  context "when execute without extra arguments" do
    before { cli.start "compose run".shellsplit }
    it { expected_exec("docker-compose", "run") }
  end

  context "when execute with arguments" do
    before { cli.start "compose run --rm bash".shellsplit }
    it { expected_exec("docker-compose", ["run", "--rm", "bash"]) }
  end

  context "when config contains project_name", config: true do
    let(:config) { {compose: {project_name: "rocket"}} }
    before { cli.start "compose run".shellsplit }
    it { expected_exec("docker-compose", ["--project-name", "rocket", "run"]) }
  end

  context "when config contains project_name with env vars", config: true, env: true do
    let(:config) { {compose: {project_name: "rocket-$RAILS_ENV"}} }
    let(:env) { {"RAILS_ENV" => "test"} }
    before { cli.start "compose run".shellsplit }
    it { expected_exec("docker-compose", ["--project-name", "rocket-test", "run"]) }
  end

  context "when config contains multiple docker-compose files", config: true do
    context "and some files are not exist" do
      let(:config) { {compose: {files: %w(file1.yml file2.yml file3.yml)}} }

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("file1.yml").and_return(true)
        allow(File).to receive(:exist?).with("file2.yml").and_return(false)
        allow(File).to receive(:exist?).with("file3.yml").and_return(true)

        cli.start "compose run".shellsplit
      end

      it { expected_exec("docker-compose", ["--file", "file1.yml", "--file", "file3.yml", "run"]) }
    end

    context "and a file name contains env var", env: true do
      let(:config) { {compose: {files: %w(file1-${DIP_OS}.yml)}} }
      let(:env) { {"DIP_OS" => "darwin"} }

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("file1-darwin.yml").and_return(true)

        cli.start "compose run".shellsplit
      end

      it { expected_exec("docker-compose", ["--file", "file1-darwin.yml", "run"]) }
    end
  end
end
