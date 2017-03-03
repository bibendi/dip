require "./spec_helper"

describe Dip do
  describe "#condig_path" do
    assert { Dip.config_path == "./dip.yml" }

    it "returns custom config path" do
      with_dip_file("./custom_dip.yml") do
        Dip.config_path.should eq "./custom_dip.yml"
      end
    end
  end

  describe "#config" do
    it "raises error" do
      with_dip_file("./spec/not-exists.yml") do
        expect_raises do
          Dip.config
        end
      end
    end

    it "returns config" do
      with_dip_file do
        Dip.config.should be_a(Dip::Config)
      end
    end
  end

  describe "#env" do
    it "reads vars from dip.yml" do
      # Remove env vars because var from ENV can broke tests,
      # for example in travis RAILS_ENV = test by default
      ENV.delete("RUBY")
      ENV.delete("RAILS_ENV")

      with_dip_file do
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
      end
    end
  end
end
