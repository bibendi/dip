# frozen_string_literal: true

describe Dip::Config do
  subject { described_class.new }

  describe "#exist?" do
    context "when file exists" do
      it { is_expected.to be_exist }
    end

    context "when file doesn't exist", :env do
      let(:env) { {"DIP_FILE" => "no.yml"} }

      it { is_expected.not_to be_exist }
    end
  end

  %i[environment compose infra interaction provision].each do |key|
    describe "##{key}" do
      context "when config file doesn't exist", :env do
        let(:env) { {"DIP_FILE" => "no.yml"} }

        it { expect { subject.public_send(key) }.to raise_error(Dip::Error) }
      end

      context "when config exists" do
        it { expect(subject.public_send(key)).not_to be_nil }
      end

      context "when config is missing" do
        let(:env) { {"DIP_FILE" => fixture_path("missing", "dip.yml")} }

        it { expect(subject.public_send(key)).not_to be_nil }
      end
    end
  end

  context "when config has override file", :env do
    let(:env) { {"DIP_FILE" => fixture_path("overridden", "dip.yml")} }

    it "rewrites an array" do
      expect(subject.compose[:files]).to eq ["docker-compose.local.yml"]
    end

    it "deep merges hashes" do
      expect(subject.interaction[:app]).to include(
        service: "backend",
        subcommands: {
          start: {command: "exec start"},
          debug: {command: "exec debug"}
        }
      )
    end
  end

  context "when config located two levels higher and overridden at one level higher", :env do
    subject { described_class.new(fixture_path("cascade", "sub_a", "sub_b")) }

    let(:env) { {"DIP_FILE" => nil} }

    it "rewrites an array" do
      expect(subject.compose[:files]).to eq ["docker-compose.local.yml"]
    end

    it "deep merges hashes" do
      expect(subject.interaction[:app]).to include(
        service: "backend",
        compose: {run_options: ["publish=80"]},
        subcommands: {
          start: {command: "exec start", compose: {run_options: ["no-deps"]}},
          debug: {command: "exec debug"}
        }
      )
    end
  end
end
