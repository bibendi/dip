# frozen_string_literal: true

describe Dip::Config do
  subject { described_class.new }

  describe "#exist?" do
    context "when file exists" do
      it { is_expected.to be_exist }
    end

    context "when file doesn't exist", env: true do
      let(:env) { {"DIP_FILE" => "no.yml"} }

      it { is_expected.to_not be_exist }
    end
  end

  [:environment, :compose, :interaction, :provision].each do |key|
    describe "##{key}" do
      context "when config file doesn't exist", env: true do
        let(:env) { {"DIP_FILE" => "no.yml"} }

        it { expect { subject.public_send(key) }.to raise_error(ArgumentError) }
      end

      context "when config exists" do
        it { expect(subject.public_send(key)).to_not be_nil }
      end
    end
  end
end
