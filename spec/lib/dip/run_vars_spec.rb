# frozen_string_literal: true

require "dip/run_vars"

describe Dip::RunVars do
  context "when no env vars" do
    it { expect(described_class.call(%w(run rspec))).to eq %w(run rspec) }
  end

  context "when env vars in argv" do
    it "parses them and stores in class var" do
      expect(described_class.call(%w(FOO=foo BAR=bar run rspec))).to eq %w(run rspec)
      expect(described_class.env).to include("FOO" => "foo", "BAR" => "bar")
    end

    context "and call multiple times" do
      it "doesn't reset previous vars" do
        expect(described_class.call(%w(FOO=foo BAR=bar run rspec))).to eq %w(run rspec)
        expect(described_class.call(%w(run rspec))).to eq %w(run rspec)
        expect(described_class.env).to include("FOO" => "foo", "BAR" => "bar")
      end
    end
  end

  context "when early_envs is present" do
    let(:env) { {"FOO" => "foo", "BAR" => "bar", "BAZ" => "baz", "DIP_EARLY_ENVS" => "FOO,BAR"} }

    specify do
      expect(described_class.call(%w(run rspec), env)).to eq %w(run rspec)
      expect(described_class.env).to include("BAZ" => "baz")
    end
  end
end
