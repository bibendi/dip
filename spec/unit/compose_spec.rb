require 'dip/commands/compose'

describe Dip::Commands::Compose do
  let(:cmd) { "run" }
  let(:argv) { [] }
  let(:command) { described_class.new(cmd, argv) }

  subject { command.execute }

  context "when execute compose only with cmd" do
    before { subject }

    it { expected_exec("docker-compose", "run") }
  end

  context "when execute compose with argv" do
    let(:argv) { %w(--rm bash) }

    before { subject }

    it { expected_exec("docker-compose", "run", "--rm", "bash") }
  end

  context "when project name is provided", config: true do
    let(:config) { {compose: {project_name: "rocket"}} }

    before { subject }

    it { expected_exec("docker-compose", "--project-name", "rocket", "run") }

    context "and project name contains env var", env: true do
      let(:config) { {compose: {project_name: "rocket-$RAILS_ENV"}} }
      let(:env) { {"RAILS_ENV" => "test"} }

      it { expected_exec("docker-compose", "--project-name", "rocket-test", "run") }
    end
  end

  context "when multiple docker-compose files", config: true do
    let(:config) { {compose: {files: %w(file2.yml file3.yml).unshift(file_1)}} }

    context "and some files are not exist" do
      let(:config) { {compose: {files: %w(file1.yml file2.yml file3.yml)}} }

      before do
        allow(File).to receive(:exist?).with("file1.yml").and_return(true)
        allow(File).to receive(:exist?).with("file2.yml").and_return(false)
        allow(File).to receive(:exist?).with("file3.yml").and_return(true)

        subject
      end

      it "runs a command only with existen files" do
        expected_exec("docker-compose", "--file", "file1.yml", "--file", "file3.yml", "run")
      end
    end

    context "and a file name contains env var", env: true do
      let(:config) { {compose: {files: %w(file1-${DIP_OS}.yml)}} }
      let(:env) { {"DIP_OS" => "darwin"} }

      before do
        allow(File).to receive(:exist?).with("file1-darwin.yml").and_return(true)

        subject
      end

      it "finds and replaces env var" do
        expected_exec("docker-compose", "--file", "file1-darwin.yml", "run")
      end
    end
  end
end
