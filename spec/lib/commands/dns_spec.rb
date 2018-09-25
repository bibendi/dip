# frozen_string_literal: true

require "shellwords"
require "dip/cli/dns"
require "dip/commands/dns"

describe Dip::Commands::DNS do
  let(:cli) { Dip::CLI::DNS }

  describe Dip::Commands::DNS::Up do
    context "when without arguments" do
      before { cli.start "up".shellsplit }
      it { expected_subshell("docker", ["network", "create", "frontend"]) }
      it do
        expected_subshell(
          "docker",
          ["run", "--detach", "--volume", "/var/run/docker.sock:/var/run/docker.sock:ro", "--restart", "always",
           "--publish", "53/udp", "--net", "frontend", "--name", "dnsdock", "aacebedo/dnsdock:latest-amd64",
           "--domain=docker"]
        )
      end
    end

    context "when option `name` is present" do
      before { cli.start "up --name foo".shellsplit }
      it { expected_subshell("docker", array_including("--name", "foo")) }
    end

    context "when option `socket` is present" do
      before { cli.start "up --socket foo".shellsplit }
      it { expected_subshell("docker", array_including("--volume", "foo:/var/run/docker.sock:ro")) }
    end

    context "when option `net` is present" do
      before { cli.start "up --net foo".shellsplit }
      it { expected_subshell("docker", ["network", "create", "foo"]) }
      it { expected_subshell("docker", array_including("--net", "foo")) }
    end

    context "when option `publish` is present" do
      before { cli.start "up --publish foo".shellsplit }
      it { expected_subshell("docker", array_including("--publish", "foo")) }
    end

    context "when option `image` is present" do
      before { cli.start "up --image foo".shellsplit }
      it { expected_subshell("docker", array_including("foo")) }
    end

    context "when option `domain` is present" do
      before { cli.start "up --domain foo".shellsplit }
      it { expected_subshell("docker", array_including("--domain=foo")) }
    end
  end

  describe Dip::Commands::DNS::Down do
    context "when without arguments" do
      before { cli.start "down".shellsplit }
      it { expected_subshell("docker", ["stop", "dnsdock"]) }
      it { expected_subshell("docker", ["rm", "-v", "dnsdock"]) }
    end

    context "when option `name` is present" do
      before { cli.start "down --name foo".shellsplit }
      it { expected_subshell("docker", ["stop", "foo"]) }
      it { expected_subshell("docker", ["rm", "-v", "foo"]) }
    end
  end

  describe Dip::Commands::DNS::IP do
    context "when without arguments" do
      before { cli.start "ip".shellsplit }
      it do
        expected_subshell("docker", array_including("inspect", "--format", /Networks.frontend.IPAddress/, "dnsdock"))
      end
    end

    context "when option `name` is present" do
      before { cli.start "ip --name foo".shellsplit }
      it { expected_subshell("docker", array_including("foo")) }
    end

    context "when option `net` is present" do
      before { cli.start "ip --net foo".shellsplit }
      it { expected_subshell("docker", array_including(/Networks.foo.IPAddress/)) }
    end
  end
end
