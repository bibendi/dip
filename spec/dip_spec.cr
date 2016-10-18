require "./spec_helper"

describe Dip do
  describe "#condig_path" do
    assert { Dip.config_path == "./dip.yml" }

    it "returns custom config path" do
      ENV["DIP_FILE"] = "./custom_dip.yml"

      Dip.config_path.should eq "./custom_dip.yml"

      ENV.delete("DIP_FILE")
    end
  end

  describe "#config" do
    it "raises error" do
      ENV["DIP_FILE"] = "./spec/not-exists.yml"

      expect_raises do
        Dip.config
      end
    end

    it "returns config" do
      ENV["DIP_FILE"] = "./spec/dip.yml"

      Dip.config.should be_a(Dip::Config)
    end
  end

  describe "#env" do
    it "reads vars from dip.yml" do
      ENV["DIP_FILE"] = "./spec/dip.yml"

      pp ENV

      Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
    end
  end
end
