# frozen_string_literal: true

describe Dip do
  it "has a version number" do
    expect(Dip::VERSION).not_to be nil
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
