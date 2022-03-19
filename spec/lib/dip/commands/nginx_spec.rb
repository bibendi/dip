# frozen_string_literal: true

require "shellwords"
require "dip/cli/nginx"
require "dip/commands/nginx"

describe Dip::Commands::Nginx do
  let(:cli) { Dip::CLI::Nginx }

  describe Dip::Commands::Nginx::Up do
    context "when without arguments" do
      before { cli.start "up".shellsplit }

      it { expected_subprocess("docker", ["network", "create", "frontend"]) }

      it do
        expected_subprocess(
          "docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest"
        )
      end
    end

    context "when option `name` is present" do
      before { cli.start "up --name foo".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name foo --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
      }
    end

    context "when option `socket` is present" do
      before { cli.start "up --socket foo".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume foo:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
      }
    end

    context "when option `net` is present" do
      before { cli.start "up --net foo".shellsplit }

      it { expected_subprocess("docker", ["network", "create", "foo"]) }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net foo --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
      }
    end

    context "when option `publish` is present" do
      before { cli.start "up --publish 80:80".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
      }

      context "when more than one port given" do
        before { cli.start "up --publish 80:80 443:443".shellsplit }

        it {
          expected_subprocess("docker",
            "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
        }
      end
    end

    context "when option `image` is present" do
      before { cli.start "up --image foo".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker foo")
      }
    end

    context "when option `domain` is present" do
      before { cli.start "up --domain foo".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=foo nginxproxy/nginx-proxy:latest")
      }
    end

    context "when option `certs` is present" do
      before { cli.start "up --certs /home/whoami/certs_storage".shellsplit }

      it {
        expected_subprocess("docker",
          "run --detach --volume /var/run/docker.sock:/tmp/docker.sock:ro --volume /home/whoami/certs_storage:/etc/nginx/certs --restart always --publish 80:80 --net frontend --name nginx --label com.dnsdock.alias=docker nginxproxy/nginx-proxy:latest")
      }
    end
  end

  describe Dip::Commands::Nginx::Down do
    context "when without arguments" do
      before { cli.start "down".shellsplit }

      it { expected_subprocess("docker", ["stop", "nginx"]) }
      it { expected_subprocess("docker", ["rm", "-v", "nginx"]) }
    end

    context "when option `name` is present" do
      before { cli.start "down --name foo".shellsplit }

      it { expected_subprocess("docker", ["stop", "foo"]) }
      it { expected_subprocess("docker", ["rm", "-v", "foo"]) }
    end
  end
end
