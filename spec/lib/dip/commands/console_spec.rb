# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/console"

describe Dip::Commands::Console do
  let(:cli) { Dip::CLI }

  describe Dip::Commands::Console::Start do
    context "when execute without start" do
      subject { cli.start "console --shell bash".shellsplit }

      it { expect { subject }.to output(/export DIP_SHELL=1/).to_stdout }
      it { expect { subject }.to output(/export DIP_EARLY_ENVS/).to_stdout }
      it { expect { subject }.to output(/function dip_clear/).to_stdout }
      it { expect { subject }.to output(/function dip_inject/).to_stdout }
      it { expect { subject }.to output(/function dip_reload/).to_stdout }
      it { expect { subject }.to output(%r{console inject --shell posix}).to_stdout }
      it { expect { subject }.to output(/function __dip_auto_reload/).to_stdout }
      it { expect { subject }.to output(/chpwd_functions\+=\(__dip_auto_reload\)/).to_stdout }
    end

    context "when the fish shell is requested" do
      subject { cli.start "console --shell fish".shellsplit }

      it { expect { subject }.to output(/set -gx DIP_SHELL 1/).to_stdout }
      it { expect { subject }.to output(/set -gx DIP_EARLY_ENVS/).to_stdout }
      it { expect { subject }.to output(/function dip_clear\n/).to_stdout }
      it { expect { subject }.to output(/function dip_reload\n/).to_stdout }
      it { expect { subject }.to output(/--on-variable PWD/).to_stdout }
      it { expect { subject }.to output(%r{console inject --shell fish \| source}).to_stdout }
      it { expect { subject }.not_to output(/export /).to_stdout }
      it { expect { subject }.to output(/function __dip_config_path/).to_stdout }
      it { expect { subject }.to output(/set -g __dip_config_path_cache/).to_stdout }
    end

    context "when the shell is autodetected from $SHELL" do
      subject { cli.start "console".shellsplit }

      around do |example|
        old = ENV["SHELL"]
        ENV["SHELL"] = "/opt/homebrew/bin/fish"
        example.run
        ENV["SHELL"] = old
      end

      it { expect { subject }.to output(/set -gx DIP_SHELL 1/).to_stdout }
    end
  end

  describe Dip::Commands::Console::Inject do
    subject { cli.start "console inject".shellsplit }

    context "when provision commands are empty" do
      it { expect { subject }.to output(/function compose/).to_stdout }
      it { expect { subject }.to output(/unset -f compose/).to_stdout }
      it { expect { subject }.to output(/function up/).to_stdout }
      it { expect { subject }.to output(/unset -f up/).to_stdout }
      it { expect { subject }.to output(/function build/).to_stdout }
      it { expect { subject }.to output(/unset -f build/).to_stdout }
      it { expect { subject }.to output(/function stop/).to_stdout }
      it { expect { subject }.to output(/unset -f stop/).to_stdout }
      it { expect { subject }.to output(/function down/).to_stdout }
      it { expect { subject }.to output(/unset -f down/).to_stdout }
      it { expect { subject }.to output(/function provision/).to_stdout }
      it { expect { subject }.to output(/unset -f provision/).to_stdout }
    end

    context "when has provision command", :config do
      let(:config) { {interaction: commands} }
      let(:commands) { {bash: {service: "app"}, rails: {service: "app", command: "rails"}} }

      it { expect { subject }.to output(/function bash/).to_stdout }
      it { expect { subject }.to output(/unset -f bash/).to_stdout }
      it { expect { subject }.to output(/function rails/).to_stdout }
      it { expect { subject }.to output(/unset -f rails/).to_stdout }
    end

    context "when an interaction command shadows a shell builtin", :config do
      let(:config) { {interaction: {jobs: {service: "app", command: "bin/jobs start"}}} }

      it "does not alias it" do
        expect { subject }.not_to output(/function jobs/).to_stdout
      end

      it "does not try to unset it either" do
        expect { subject }.not_to output(/unset -f jobs|functions -e .*jobs/).to_stdout
      end

      it "warns on stderr instead" do
        expect { subject }.to output(/skipping alias `jobs`/).to_stderr
      end

      it "still aliases commands that don't collide" do
        expect { subject }.to output(/function compose/).to_stdout
      end
    end

    it "does not run full schema validation (runs on every automatic shell reload)" do
      expect_any_instance_of(Dip::Config).not_to receive(:validate)
      subject
    end

    it "does not leak DIP_SKIP_VALIDATION into the environment afterwards" do
      expect { subject }.not_to change { ENV.key?("DIP_SKIP_VALIDATION") }.from(false)
    end
  end

  describe "#{Dip::Commands::Console::Inject} for fish" do
    subject { cli.start "console inject --shell fish".shellsplit }

    context "when provision commands are empty" do
      it { expect { subject }.to output(/function compose; dip compose \$argv; end/).to_stdout }
      it { expect { subject }.to output(/function provision; dip provision \$argv; end/).to_stdout }
      it { expect { subject }.to output(/function dip_clear; functions -e .*compose.*; end/).to_stdout }
      it { expect { subject }.not_to output(/unset -f/).to_stdout }
    end

    context "when has provision command", :config do
      let(:config) { {interaction: {rails: {service: "app", command: "rails"}}} }

      it { expect { subject }.to output(/function rails; dip rails \$argv; end/).to_stdout }
      it { expect { subject }.to output(/functions -e rails /).to_stdout }
    end
  end
end
