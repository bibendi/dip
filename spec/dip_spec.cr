require "./spec_helper"

describe Dip do
  describe "#condig_path" do
    it "returns default config path" do
      Dip.config_path == "./dip.yml"
    end

    it "returns custom config path" do
      with_dip_file("./custom_dip.yml") do
        Dip.config_path.should eq "./custom_dip.yml"
      end
    end
  end

  describe "#config" do
    it "raises error" do
      Dip.reset!

      with_dip_file("./spec/not-exists.yml") do
        expect_raises(Errno, "opening file './spec/not-exists.yml' with mode 'r': No such file or directory") do
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
      with_dip_file do
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
      end
    end
  end
end
