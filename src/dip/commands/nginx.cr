require "../command"

module Dip::Cli::Commands
  class Nginx < ::Cli::Supercommand
    command "up"
    command "down"

    class Options
      help
    end

    class Help
      caption "Run nginx-proxy server"
    end

    module Commands
      class Up < ::Dip::Command
        class Options
          string %w(-s --socket), var: "PATH", default: "/var/run/docker.sock"
          string %w(--net), var: "NET", default: "frontend"
          string %w(--ip), var: "IP", default: "0.0.0.0"
          string %w(-p --port), var: "PORT", default: "80"
          string %w(--name), var: "NAME", default: "nginx"
          string %w(--image), var: "IMAGE", default: "jwilder/nginx-proxy:latest"
          help
        end

        def run
          exec_cmd!("docker network inspect #{options.net} > /dev/null 2>&1 || docker network create #{options.net}")
          exec_cmd!("docker run #{docker_args} #{options.image}")
        end

        private def docker_args
          result = %w()
          result << "--detach"
          result << "--volume #{options.socket}:/tmp/docker.sock:ro"
          result << "--restart always"
          result << "--publish #{options.ip}:#{options.port}:80"
          result << "--net #{options.net}"
          result << "--name=#{options.name}"
          result.join(' ')
        end
      end

      class Down < ::Dip::Command
        class Options
          string %w(--name), var: "NAME", default: "nginx"
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
