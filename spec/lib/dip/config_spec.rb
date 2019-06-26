# frozen_string_literal: true

describe Dip::Config do
  subject { described_class.new }

  describe ".exist?" do
    context "when file exists" do
      it { expect(described_class).to be_exist }
    end

    context "when file doesn't exist", env: true do
      let(:env) { {"DIP_FILE" => "no.yml"} }

      it { expect(described_class).to_not be_exist }
    end
  end

  %i[environment compose interaction provision].each do |key|
    describe "##{key}" do
      context "when config file doesn't exist", env: true do
        let(:env) { {"DIP_FILE" => "no.yml"} }

        it { expect { subject.public_send(key) }.to raise_error(ArgumentError) }
      end

      context "when config exists" do
        it { expect(subject.public_send(key)).to_not be_nil }
      end
    end
  end

  context "when config has override file", env: true do
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
end
