require "../../spec_helper"

describe Dip::Cli::Commands::Dns do
  with_dip_file do
    describe "#up" do
      it "starts dns container" do
        Dip::Cli::Commands::Dns.run(%w(up)) do |cmd|
          cmd.out.gets_to_end.should contain("docker run \
                                                    --detach \
                                                    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
                                                    --restart always \
                                                    --publish 53/udp \
                                                    --net frontend \
                                                    --name=dnsdock aacebedo/dnsdock:latest-amd64")
        end
      end

      it "starts dns container with custom ip and socket" do
        Dip::Cli::Commands::Dns.run(%w(up --publish 8.8.8.8:53:53/udp -s /var/tmp/tmp.sock)) do |cmd|
          cmd.out.gets_to_end.should contain("docker run \
                                                    --detach \
                                                    --volume /var/tmp/tmp.sock:/var/run/docker.sock:ro \
                                                    --restart always \
                                                    --publish 8.8.8.8:53:53/udp \
                                                    --net frontend \
                                                    --name=dnsdock aacebedo/dnsdock:latest-amd64")
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

    describe "#ip" do
      it "get running ip of dns container" do
        Dip::Cli::Commands::Dns.run(%w(ip)) do |cmd|
          output = cmd.out.gets_to_end

          output.should contain("docker inspect" \
                                " --format '{{ .NetworkSettings.Networks.frontend.IPAddress }}'" \
                                " dnsdock 2>/dev/null")
        end
      end
    end
  end
end
