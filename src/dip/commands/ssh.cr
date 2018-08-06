require "../command"

module Dip::Cli::Commands
  class Ssh < ::Cli::Supercommand
    command "up"
    command "add", aliased: "up"
    command "down"
    command "restart"
    command "status"

    class Options
      help
    end

    class Help
      caption "Run ssh agent"
    end

    module Commands
      class Up < ::Dip::Command
        class Options
          string %w(-k --key), var: "PATH", default: "$HOME/.ssh/id_rsa"
          string %w(-v --volume), var: "PATH", default: "$HOME"
          bool %w(-t -interactive), not: %w(-T -Interactive), desc: "Interactive tty", default: true
          help
        end

        def run
          exec_cmd!("docker volume create --name ssh_data")
          exec_cmd!("docker run --detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent")

          key = options.key.sub("$HOME", ENV["HOME"])
          exec_cmd!("docker run #{docker_args} whilp/ssh-agent ssh-add #{key}")
        end

        private def docker_args
          result = %w()
          result << "--rm"
          volume = options.volume.sub("$HOME", ENV["HOME"])
          result << "--volume ssh_data:/ssh -v #{volume}:#{volume}"
          result << "--interactive --tty" if options.interactive?
          result.join(' ')
        end
      end

      class Down < ::Dip::Command
        def run
          exec_cmd("docker stop ssh-agent")
          exec_cmd("docker rm -v ssh-agent")
          exec_cmd("docker volume rm ssh_data")
        end
      end

      class Restart < Up
        def run
          exec_cmd!("#{Process.executable_path} ssh down")
          super
        end
      end

      class Status < ::Dip::Command
        def run
          exec_cmd!("docker inspect --format '{{.State.Status}}' ssh-agent")
        end
      end
    end
  end
end
