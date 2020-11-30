# frozen_string_literal: true

require "shellwords"
require "dip/cli"
require "dip/commands/console"

describe Dip::Commands::Console do
  let(:cli) { Dip::CLI }

  describe Dip::Commands::Console::Start do
    context "when execute without start" do
      subject { cli.start "console".shellsplit }

      it { expect { subject }.to output(/export DIP_SHELL=1/).to_stdout }
      it { expect { subject }.to output(/export DIP_EARLY_ENVS/).to_stdout }
      it { expect { subject }.to output(/function dip_clear/).to_stdout }
      it { expect { subject }.to output(/function dip_inject/).to_stdout }
      it { expect { subject }.to output(/function dip_reload/).to_stdout }
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

    context "when has provision command", config: true do
      let(:config) { {interaction: commands} }
      let(:commands) { {bash: {service: "app"}, rails: {service: "app", command: "rails"}} }

      it { expect { subject }.to output(/function bash/).to_stdout }
      it { expect { subject }.to output(/unset -f bash/).to_stdout }
      it { expect { subject }.to output(/function rails/).to_stdout }
      it { expect { subject }.to output(/unset -f rails/).to_stdout }
    end
  end
end
