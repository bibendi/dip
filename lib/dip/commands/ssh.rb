# frozen_string_literal: true

require "shellwords"
require_relative '../command'

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
          subshell("docker", "volume create --name ssh_data".shellsplit, out: File::NULL, err: File::NULL)

          subshell(
            "docker",
            "run #{user_args} --detach --volume ssh_data:/ssh --name=ssh-agent whilp/ssh-agent".shellsplit
          )

          key = Dip.env.interpolate(@key)
          subshell("docker", "run #{container_args} whilp/ssh-agent ssh-add #{key}".shellsplit)
        end

        private

        def user_args
          "-u #{@user}" if @user
        end

        def container_args
          result = %w(--rm)
          volume = Dip.env.interpolate(@volume)
          result << "--volume ssh_data:/ssh"
          result << "--volume #{volume}:#{volume}"
          result << "--interactive --tty" if @interactive
          result.join(' ')
        end
      end

      class Down < Dip::Command
        def execute
          subshell("docker", "stop ssh-agent".shellsplit, panic: false, out: File::NULL, err: File::NULL)
          subshell("docker", "rm -v ssh-agent".shellsplit, panic: false, out: File::NULL, err: File::NULL)
          subshell("docker", "volume rm ssh_data".shellsplit, panic: false, out: File::NULL, err: File::NULL)
        end
      end

      class Status < Dip::Command
        def execute
          subshell("docker", "inspect --format '{{.State.Status}}' ssh-agent".shellsplit)
        end
      end
    end
  end
end
