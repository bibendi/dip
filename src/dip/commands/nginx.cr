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
          string %w(--publish), var: "PUBLISH", default: "80:80"
          string %w(--name), var: "NAME", default: "nginx"
          string %w(--image), var: "IMAGE", default: "abakpress/nginx-proxy:latest"
          string %w(--domain), var: "DOMAIN", default: "docker"
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
          result << "--publish #{options.publish}"
          result << "--net #{options.net}"
          result << "--name=#{options.name}"
          result << "--label com.dnsdock.alias=#{options.domain}"
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
