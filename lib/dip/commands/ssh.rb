# frozen_string_literal: true

require "shellwords"
require_relative "../command"

module Dip
  module Commands
    module SSH
      class Up < Dip::Command
        def initialize(key:, volume:, interactive:, user: nil)
          @key = key
          @volume = volume
          @interactive = interactive
          @user = user
        end

        def execute
          exec_subprocess("docker", "volume create --name ssh_data", out: File::NULL, err: File::NULL)

          exec_subprocess(
            "docker",
            "run #{user_args}--detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent"
          )

          key = Dip.env.interpolate(@key)
          exec_subprocess("docker", "run #{container_args} whilp/ssh-agent ssh-add #{key}")
        end

        private

        def user_args
          "-u #{@user} " if @user
        end

        def container_args
          result = %w[--rm]
          volume = Dip.env.interpolate(@volume)
          result << "--volume ssh_data:/ssh"
          result << "--volume #{volume}:#{volume}"
          result << "--interactive --tty" if @interactive
          result.join(" ")
        end
      end

      class Down < Dip::Command
        def execute
          exec_subprocess("docker", "stop ssh-agent", panic: false, out: File::NULL, err: File::NULL)
          exec_subprocess("docker", "rm -v ssh-agent", panic: false, out: File::NULL, err: File::NULL)
          exec_subprocess("docker", "volume rm ssh_data", panic: false, out: File::NULL, err: File::NULL)
        end
      end

      class Status < Dip::Command
        def execute
          exec_subprocess("docker", "inspect --format '{{.State.Status}}' ssh-agent")
        end
      end
    end
  end
end
