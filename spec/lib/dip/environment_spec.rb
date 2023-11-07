# frozen_string_literal: true

require "spec_helper"

describe Dip::Environment do
  subject { described_class.new(vars) }

  let(:vars) { {} }

  context "when vars is empty" do
    it { is_expected.to be_truthy }
  end

  context "when vars provided" do
    subject { described_class.new(vars).vars }

    context "and its don't exist in ENV" do
      let(:vars) { {"FOO" => "foo"} }

      it { is_expected.to include("FOO" => "foo") }
    end

    context "and its exist in ENV", :env do
      let(:vars) { {"FOO" => "foo"} }
      let(:env) { {"FOO" => "bar"} }

      it { is_expected.to include("FOO" => "bar") }
    end

    context "and some vars were interpolated", :env do
      let(:vars) { {"BAZ" => "baz", "FOO" => "foo-${BAR}-$BAZ"} }
      let(:env) { {"BAR" => "bar"} }

      it { is_expected.to include("BAZ" => "baz", "FOO" => "foo-bar-baz") }
    end
  end

  describe "#interpolate" do
    subject { described_class.new(vars).interpolate(key) }

    let(:key) { "foo $BAR baz" }

    it { is_expected.to eq "foo $BAR baz" }

    context "when vars are provided" do
      let(:vars) { {"BAR" => "bar"} }

      it { is_expected.to eq "foo bar baz" }
    end
  end
end
