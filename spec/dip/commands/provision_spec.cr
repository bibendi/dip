require "../../spec_helper"

describe Dip::Cli::Commands::Provision do
  with_dip_file do
    it "runs commands from provision section" do
      Dip::Cli::Commands::Provision.run do |cmd|
        output = cmd.out.gets_to_end

        output.should contain("bundle install")
        output.should contain("bundle exec rake db:migrate")
      end
    end
  end
end
