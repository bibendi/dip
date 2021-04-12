# frozen_string_literal: true

require "shellwords"
require "dip/cli/dns"
require "dip/commands/dns"

describe Dip::Commands::DNS do
  let(:cli) { Dip::CLI::DNS }

  describe Dip::Commands::DNS::Up do
    let(:volume) { "--volume /var/run/docker.sock:/var/run/docker.sock:ro" }
    let(:net) { "--net frontend" }
    let(:name) { "--name dnsdock" }
    let(:domain) { "--domain=docker" }
    let(:port) { "--publish 53/udp" }
    let(:image) { "aacebedo/dnsdock:latest-amd64" }
    let(:cmd) { "run --detach #{volume} --restart always #{port} #{net} #{name} #{image} #{domain}" }

    context "when without arguments" do
      before { cli.start "up".shellsplit }
      it { expected_subshell("docker", ["network", "create", "frontend"]) }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `name` is present" do
      let(:name) { "--name foo" }
      before { cli.start "up --name foo".shellsplit }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `socket` is present" do
      let(:volume) { "--volume foo:/var/run/docker.sock:ro" }
      before { cli.start "up --socket foo".shellsplit }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `net` is present" do
      let(:net) { "--net foo" }
      before { cli.start "up --net foo".shellsplit }
      it { expected_subshell("docker", ["network", "create", "foo"]) }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `publish` is present" do
      let(:port) { "--publish foo" }
      before { cli.start "up --publish foo".shellsplit }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `image` is present" do
      let(:image) { "foo" }
      before { cli.start "up --image foo".shellsplit }
      it { expected_subshell("docker", cmd) }
    end

    context "when option `domain` is present" do
      let(:domain) { "--domain=foo" }
      before { cli.start "up --domain foo".shellsplit }
      it { expected_subshell("docker", cmd) }
    end
  end

  describe Dip::Commands::DNS::Down do
    context "when without arguments" do
      before { cli.start "down".shellsplit }
      it { expected_subshell("docker", "stop dnsdock") }
      it { expected_subshell("docker", "rm -v dnsdock") }
    end

    context "when option `name` is present" do
      before { cli.start "down --name foo".shellsplit }
      it { expected_subshell("docker", "stop foo") }
      it { expected_subshell("docker", "rm -v foo") }
    end
  end

  describe Dip::Commands::DNS::IP do
    context "when without arguments" do
      before { cli.start "ip".shellsplit }
      it do
        expected_subshell("docker", "inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' dnsdock")
      end
    end

    context "when option `name` is present" do
      before { cli.start "ip --name foo".shellsplit }
      it { expected_subshell("docker", "inspect --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}' foo") }
    end

    context "when option `net` is present" do
      before { cli.start "ip --net foo".shellsplit }
      it { expected_subshell("docker", "inspect --format '{{ .NetworkSettings.Networks.foo.IPAddress }}' dnsdock") }
    end
  end
end
