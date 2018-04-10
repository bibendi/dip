require "../command"

module Dip::Cli::Commands
  class Dns < ::Cli::Supercommand
    command "up"
    command "down"
    command "ip"

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
          string %w(--net), var: "NET", default: "frontend"
          string %w(--publish), var: "PUBLISH", default: "53/udp"
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
          result << "--publish #{options.publish}"
          result << "--net #{options.net}"
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

      class Ip < ::Dip::Command
        class Options
          string %w(--name), var: "NAME", default: "dnsdock"
          string %w(--net), var: "NET", default: "frontend"
          help
        end

        def run
          exec_cmd("docker inspect" \
                   " --format '{{ .NetworkSettings.Networks.#{options.net}.IPAddress }}'" \
                   " #{options.name} 2>/dev/null")
        end
      end
    end
  end
end
