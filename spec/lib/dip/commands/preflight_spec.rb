# frozen_string_literal: true

require "dip/cli"
require "dip/commands/preflight"

describe Dip::Commands::Preflight, :config do
  let(:cli) { Dip::CLI }
  let(:config) { {preflight: commands} }

  context "with no preflight commands configured" do
    let(:commands) { [] }

    before { cli.start "compose run".shellsplit }

    it { expected_exec("docker", "compose run") }
  end

  context "when triggered via `dip compose ...`" do
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "compose run".shellsplit
    end

    it { expected_subprocess("./bin/check-credentials", []) }
    it { expected_exec("docker", "compose run") }
  end

  context "when triggered via `dip up` (delegates to compose)" do
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start ["up"]
    end

    it "fires preflight exactly once" do
      expect(exec_subprocess_runner).to have_received(:call)
        .with("./bin/check-credentials", kind_of(Hash))
        .once
    end
  end

  context "when triggered via `dip ktl ...`" do
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "ktl get pods".shellsplit
    end

    it { expected_subprocess("./bin/check-credentials", []) }
    it { expected_exec("kubectl", "get pods") }
  end

  context "when triggered via `dip run <interaction>` with a service runner" do
    let(:config) { {preflight: commands, interaction: {bash: {service: "app"}}} }
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "run bash".shellsplit
    end

    it "fires preflight exactly once (no double execution via Compose)" do
      expect(exec_subprocess_runner).to have_received(:call)
        .with("./bin/check-credentials", kind_of(Hash))
        .once
    end

    it { expected_exec("docker", ["compose", "run", "--rm", "app"]) }
  end

  context "when triggered via `dip run <interaction>` with a pod runner" do
    let(:config) { {preflight: commands, interaction: {ksh: {pod: "web", command: "sh"}}} }
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "run ksh".shellsplit
    end

    it { expected_subprocess("./bin/check-credentials", []) }
  end

  context "when triggered via `dip run <interaction>` with a local runner" do
    let(:config) { {preflight: commands, interaction: {hello: {command: "echo hi"}}} }
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "run hello".shellsplit
    end

    it { expected_subprocess("./bin/check-credentials", []) }
  end

  context "when triggered via the interaction shorthand `dip <name>`" do
    let(:config) { {preflight: commands, interaction: {bash: {service: "app"}}} }
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start ["bash"]
    end

    it "fires preflight exactly once" do
      expect(exec_subprocess_runner).to have_received(:call)
        .with("./bin/check-credentials", kind_of(Hash))
        .once
    end
  end

  context "when `dip down --all` is invoked (intentionally skipped)" do
    let(:commands) { ["./bin/check-credentials"] }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "down --all".shellsplit
    end

    it "does not fire preflight" do
      expect(exec_subprocess_runner).not_to have_received(:call)
        .with("./bin/check-credentials", kind_of(Hash))
    end
  end

  context "when a preflight command contains env interpolation", :env do
    let(:commands) { ["echo $RAILS_ENV"] }
    let(:env) { {"RAILS_ENV" => "development"} }

    before do
      allow(exec_subprocess_runner).to receive(:call).and_return(true)
      cli.start "compose run".shellsplit
    end

    it { expected_subprocess("echo development", []) }
  end
end
