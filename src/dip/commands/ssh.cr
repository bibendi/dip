require "../command"

module Dip::Cli::Commands
  class Ssh < ::Cli::Supercommand
    command "add", aliased: "up"
    command "down"
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
          exec!("docker volume create --name ssh_data")
          exec!("docker run --detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent")

          key = options.key.sub("$HOME", ENV["HOME"])
          exec!("docker run #{docker_args} whilp/ssh-agent ssh-add #{key}")
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
          exec!("docker stop ssh-agent")
          exec!("docker rm -v ssh-agent")
          exec!("docker volume rm ssh_data")
        end
      end

      class Status < ::Dip::Command
        def run
          exec!("docker inspect --format '{{.State.Status}}' ssh-agent 2 > /dev/null")
        end
      end
    end
  end
end
