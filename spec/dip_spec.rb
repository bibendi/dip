RSpec.describe Dip do
  it "has a version number" do
    expect(Dip::VERSION).not_to be nil
  end

  describe ".config_path" do
    it "uses default path" do
      with_env("DIP_FILE" => nil) do
        expect(Dip.config_path).to eq "./dip.yml"
      end
    end

    it "gets path from env var" do
      with_env("DIP_FILE" => "exptected/dip.yml") do
        expect(Dip.config_path).to eq "exptected/dip.yml"
      end
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
end
