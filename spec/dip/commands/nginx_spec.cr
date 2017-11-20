require "../../spec_helper"

describe Dip::Cli::Commands::Nginx do
  with_dip_file do
    describe "#up" do
      it "starts an nginx container" do
        Dip::Cli::Commands::Nginx.run(%w(up)) do |cmd|
          output = cmd.out.gets_to_end

          output.should contain("docker network inspect nginx > /dev/null 2>&1 || docker network create nginx")
          output.should contain("docker run \
                                   --detach \
                                   --volume /var/run/docker.sock:/tmp/docker.sock:ro \
                                   --restart always \
                                   --publish 0.0.0.0:80:80 \
                                   --net nginx \
                                   --name=nginx jwilder/nginx-proxy:latest")
        end
      end
    end

    describe "#down" do
      it "stops dns container" do
        Dip::Cli::Commands::Dns.run(%w(down)) do |cmd|
          output = cmd.out.gets_to_end

          output.should contain("docker stop dnsdock")
          output.should contain("docker rm -v dnsdock")
        end
      end
    end
  end
end
