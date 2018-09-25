# frozen_string_literal: true

describe Dip do
  it "has a version number" do
    expect(Dip::VERSION).not_to be nil
  end

  describe ".config_path" do
    context "when by default" do
      it { expect(Dip.config_path).to eq "./dip.yml" }
    end

    context "when path fron env", env: true do
      let(:env) { {"DIP_FILE" => "exptected/dip.yml"} }
      it { expect(Dip.config_path).to eq "exptected/dip.yml" }
    end
  end

  describe ".config" do
    it "initializes the config" do
      expect(Dip.config).to be_is_a Dip::Config
    end
  end

  describe ".env" do
    it "initializes the environment" do
      expect(Dip.config).to be_is_a Dip::Config
    end
  end

  describe ".test?" do
    it { expect(Dip.test?).to be true }
  end

  describe ".debug?" do
    it { expect(Dip.debug?).to be false }

    context "when debug is running", env: true do
      let(:env) { {"DIP_ENV" => "debug"} }
      it { expect(Dip.debug?).to be true }
    end
  end
end
