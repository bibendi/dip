# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/kubectl"

describe Dip::Commands::Kubectl do
  let(:cli) { Dip::CLI }

  context "when execute without extra arguments" do
    before { cli.start "ktl get pods".shellsplit }

    it { expected_exec("kubectl", ["get", "pods"]) }
  end

  context "when execute with arguments" do
    before { cli.start "ktl exec app -- ls -l".shellsplit }

    it { expected_exec("kubectl", ["exec", "app", "--", "ls", "-l"]) }
  end

  context "when config contains namespace", :config do
    let(:config) { {kubectl: {namespace: "rocket"}} }

    before { cli.start "ktl get pods".shellsplit }

    it { expected_exec("kubectl", ["--namespace", "rocket", "get", "pods"]) }
  end

  context "when config contains namespace with env vars", :config, :env do
    let(:config) { {kubectl: {namespace: "rocket-${STAGE}"}} }
    let(:env) { {"STAGE" => "test"} }

    before { cli.start "ktl get pods".shellsplit }

    it { expected_exec("kubectl", ["--namespace", "rocket-test", "get", "pods"]) }
  end

  context "when config contains namespace with empty env vars", :config, :env do
    let(:config) { {kubectl: {namespace: "rocket-${STAGE}"}} }
    let(:env) { {"STAGE" => ""} }

    before { cli.start "ktl get pods".shellsplit }

    it { expected_exec("kubectl", ["--namespace", "rocket", "get", "pods"]) }
  end
end
