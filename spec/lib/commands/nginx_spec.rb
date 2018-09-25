# frozen_string_literal: true

require "shellwords"
require "dip/cli/nginx"
require "dip/commands/nginx"

describe Dip::Commands::Nginx do
  let(:cli) { Dip::CLI::Nginx }

  describe Dip::Commands::Nginx::Up do
    context "when without arguments" do
      before { cli.start "up".shellsplit }
      it { expected_subshell("docker", ["network", "create", "frontend"]) }
      it do
        expected_subshell(
          "docker",
          ["run", "--detach", "--volume", "/var/run/docker.sock:/tmp/docker.sock:ro", "--restart", "always",
           "--publish", "80:80", "--net", "frontend", "--name", "nginx", "--label", "com.dnsdock.alias=docker",
           "bibendi/nginx-proxy:latest"]
        )
      end
    end

    context "when option `name` is present" do
      before { cli.start "up --name foo".shellsplit }
      it { expected_subshell("docker", array_including("--name", "foo")) }
    end

    context "when option `socket` is present" do
      before { cli.start "up --socket foo".shellsplit }
      it { expected_subshell("docker", array_including("--volume", "foo:/tmp/docker.sock:ro")) }
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
      it { expected_subshell("docker", array_including("com.dnsdock.alias=foo")) }
    end
  end

  describe Dip::Commands::Nginx::Down do
    context "when without arguments" do
      before { cli.start "down".shellsplit }
      it { expected_subshell("docker", ["stop", "nginx"]) }
      it { expected_subshell("docker", ["rm", "-v", "nginx"]) }
    end

    context "when option `name` is present" do
      before { cli.start "down --name foo".shellsplit }
      it { expected_subshell("docker", ["stop", "foo"]) }
      it { expected_subshell("docker", ["rm", "-v", "foo"]) }
    end
  end
end
