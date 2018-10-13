# frozen_string_literal: true

require "dip/run_vars"

describe Dip::RunVars do
  context "when no env vars" do
    it { expect(described_class.call(%w(run rspec))).to eq %w(run rspec) }
  end

  context "when env vars in argv" do
    specify do
      expect(described_class.call(%w(FOO=foo BAR=bar run rspec))).
        to eq %w(run rspec --x-dip-run-vars=FOO:foo BAR:bar)
    end
  end

  context "when early_envs is present" do
    let(:env) { {"FOO" => "foo", "BAR" => "bar", "BAZ" => "baz", "DIP_EARLY_ENVS" => "FOO,BAR"} }

    it { expect(described_class.call(%w(run rspec), env)).to eq %w(run rspec --x-dip-run-vars=BAZ:baz) }
  end
end
