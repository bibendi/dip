# frozen_string_literal: true

require "shellwords"
require "dip/cli/ssh"
require "dip/commands/ssh"

describe Dip::Commands::SSH do
  let(:cli) { Dip::CLI::SSH }

  describe Dip::Commands::SSH::Up do
    context "when without arguments", env: true do
      let(:env) { {"HOME" => "/user"} }

      before { cli.start "up".shellsplit }

      it { expected_subshell("docker", "volume create --name ssh_data") }
      it { expected_subshell("docker", "run --detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent") }
      it { expected_subshell("docker", "run --rm --volume ssh_data:/ssh --volume /user:/user --interactive --tty whilp/ssh-agent ssh-add /user/.ssh/id_rsa") }
    end

    context "when option `key` is present" do
      before { cli.start "up --key /foo/bar-baz-rsa".shellsplit }
      it { expected_subshell("docker", "run --rm --volume ssh_data:/ssh --volume /root:/root --interactive --tty whilp/ssh-agent ssh-add /foo/bar-baz-rsa") }
    end

    context "when option `volume` is present" do
      before { cli.start "up --volume /foo/.ssh".shellsplit }
      it { expected_subshell("docker", "run --rm --volume ssh_data:/ssh --volume /foo/.ssh:/foo/.ssh --interactive --tty whilp/ssh-agent ssh-add /root/.ssh/id_rsa") }
    end

    context "when option `user` is present" do
      before { cli.start "up -u 1000".shellsplit }
      it { expected_subshell("docker", "run -u 1000 --detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent") }
    end
  end

  describe Dip::Commands::SSH::Down do
    before { cli.start "down".shellsplit }

    it { expected_subshell("docker", ["stop", "ssh-agent"]) }
    it { expected_subshell("docker", ["rm", "-v", "ssh-agent"]) }
    it { expected_subshell("docker", ["volume", "rm", "ssh_data"]) }
  end

  describe Dip::Commands::SSH::Status do
    before { cli.start "status".shellsplit }

    it { expected_subshell("docker", "inspect --format {{.State.Status}} ssh-agent") }
  end
end
