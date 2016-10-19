require "../spec_helper"

describe Dip::Environment do
  default_vars = {"foo" => "bar", "baz" => "qux"}

  it "initializes with default vars" do
    Dip::Environment.new(default_vars).vars.should eq(default_vars)
  end

  it "replaces default vars with variable from env" do
    ENV["foo"] = "another"
    Dip::Environment.new(default_vars).vars.should eq({"foo" => "another", "baz" => "qux"})
    ENV.delete("foo")
  end

  describe "#merge" do
    it "merges default vars with new vars" do
      env = Dip::Environment.new(default_vars)
      env.merge!({"test" => "abc"})

      env.vars.should eq({"foo" => "bar", "baz" => "qux", "test" => "abc"})
    end

    it "replaces default vars if var exist in new vars" do
      env = Dip::Environment.new(default_vars)
      env.merge!({"test" => "abc", "foo" => "qwerty"})

      env.vars.should eq({"foo" => "qwerty", "baz" => "qux", "test" => "abc"})
    end
  end
end
