# frozen_string_literal: true

require "spec_helper"

describe Dip::Environment do
  let(:vars) { {} }
  subject { described_class.new(vars) }

  context "when vars is empty" do
    it { is_expected.to be_truthy }
  end

  context "when vars provided" do
    subject { described_class.new(vars).vars }

    context "and its don't exist in ENV" do
      let(:vars) { {"FOO" => "foo"} }
      it { is_expected.to include("FOO" => "foo") }
    end

    context "and its exist in ENV", env: true do
      let(:vars) { {"FOO" => "foo"} }
      let(:env) { {"FOO" => "bar"} }
      it { is_expected.to include("FOO" => "bar") }
    end

    context "and some vars were interpolated", env: true do
      let(:vars) { {"BAZ" => "baz", "FOO" => "foo-${BAR}-$BAZ"} }
      let(:env) { {"BAR" => "bar"} }
      it { is_expected.to include("BAZ" => "baz", "FOO" => "foo-bar-baz") }
    end
  end
end
