require "../command"

module Dip::Cli::Commands
  class Dns < ::Cli::Supercommand
    command "up"
    command "down"

    class Options
      help
    end

    class Help
      caption "Run dns server"
    end

    module Commands
      class Up < ::Dip::Command
        class Options
          string %w(-s --socket), var: "PATH", default: "/var/run/docker.sock"
          string %w(--ip), var: "IP", default: "172.17.0.1"
          string %w(--name), var: "NAME", default: "dnsdock"
          string %w(--image), var: "IMAGE", default: "aacebedo/dnsdock:latest-amd64"
          string %w(--domain), var: "DOMAIN", default: "docker"
          help
        end

        def run
          exec_cmd!("docker run #{docker_args} #{options.image} --domain=#{options.domain}")
        end

        private def docker_args
          result = %w()
          result << "--detach"
          result << "--volume #{options.socket}:/var/run/docker.sock:ro"
          result << "--restart always"
          result << "--publish #{options.ip}:53:53/udp"
          result << "--name=#{options.name}"
          result.join(' ')
        end
      end

      class Down < ::Dip::Command
        class Options
          string %w(--name), var: "NAME", default: "dnsdock"
          help
        end

        def run
          exec_cmd("docker stop #{options.name}")
          exec_cmd("docker rm -v #{options.name}")
        end
      end
    end
  end
end
