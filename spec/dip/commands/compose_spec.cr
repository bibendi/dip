require "../../spec_helper"

describe Dip::Cli::Commands::Compose do
  with_dip_file do
    it "runs compose command" do
      Dip::Cli::Commands::Compose.run(%w(down)) do |cmd|
        cmd.out.gets_to_end.should contain("docker-compose --file spec/app/docker-compose.yml \
                                                           --file spec/app/docker-compose.development.yml \
                                                           --project-name test-projectdevelopment down")
      end
    end

    it "runs command with args from dip.yml" do
      Dip::Cli::Commands::Compose.run(%w(run bundle)) do |cmd|
        cmd.out.gets_to_end.should contain("docker-compose --file spec/app/docker-compose.yml \
                                                           --file spec/app/docker-compose.development.yml \
                                                           --project-name test-projectdevelopment \
                                                           run \
                                                           -e RUBY=2.3.1 \
                                                           -e RAILS_ENV=development \
                                                           bundle")
      end
    end
  end
end
