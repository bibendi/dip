require "../../spec_helper"

describe Dip::Cli::Commands::Run do
  with_dip_file do
    it "runs command" do
      Dip::Cli::Commands::Run.run(%w(rake)) do |cmd|
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
        cmd.out.gets_to_end.should contain("compose run --rm app bundle exec rake")
      end
    end

    it "runs command with hard env vars" do
      Dip.env.hard_vars = {"MY_VAR" => "OK"}
      Dip::Cli::Commands::Run.run(%w(rake)) do |cmd|
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
        cmd.out.gets_to_end.should contain("compose run --rm -e MY_VAR=OK app bundle exec rake")
      end
      Dip.env.hard_vars.clear
    end

    it "runs subcommand" do
      Dip::Cli::Commands::Run.run(%w(rails c)) do |cmd|
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
        cmd.out.gets_to_end.should contain("compose run --rm app bundle exec rails c")
      end
    end

    it "runs subcommand with hard env vars" do
      Dip.env.hard_vars = {"MY_VAR" => "OK"}
      Dip::Cli::Commands::Run.run(%w(rails c)) do |cmd|
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "development"})
        cmd.out.gets_to_end.should contain("compose run --rm -e MY_VAR=OK app bundle exec rails c")
      end
      Dip.env.hard_vars.clear
    end

    it "runs command with specific file" do
      Dip::Cli::Commands::Run.run(%w(rspec spec/test_spec.rb)) do |cmd|
        Dip.env.vars.should eq({"RUBY" => "2.3.1", "RAILS_ENV" => "test"})
        cmd.out.gets_to_end.should contain("compose run --rm app bundle exec rspec spec/test_spec.rb")
      end
    end

    it "runs command with compose options" do
      Dip::Cli::Commands::Run.run(%w(irb)) do |cmd|
        cmd.out.gets_to_end.should contain("compose run --rm --no-deps --workdir='/app'")
      end
    end
  end
end
