# frozen_string_literal: true

describe Dip do
  it "has a version number" do
    expect(Dip::VERSION).not_to be_nil
  end

  describe ".config" do
    it "initializes the config" do
      expect(described_class.config).to be_is_a Dip::Config
    end
  end

  describe ".env" do
    it "initializes the environment" do
      expect(described_class.config).to be_is_a Dip::Config
    end
  end

  describe ".test?" do
    it { expect(described_class.test?).to be true }
  end

  describe ".debug?" do
    it { expect(described_class.debug?).to be false }

    context "when debug is running", env: true do
      let(:env) { {"DIP_ENV" => "debug"} }

      it { expect(described_class.debug?).to be true }
    end
  end
end
