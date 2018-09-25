# frozen_string_literal: true

require "shellwords"
require_relative '../command'

module Dip
  module Commands
    module DNS
      class Up < Dip::Command
        def initialize(name:, socket:, net:, publish:, image:, domain:)
          @name = name
          @socket = socket
          @net = net
          @publish = publish
          @image = image
          @domain = domain
        end

        def execute
          subshell("docker", "network create #{@net}".shellsplit, panic: false, err: File::NULL)
          subshell("docker", "run #{container_args} #{@image} --domain=#{@domain}".shellsplit)
        end

        private

        def container_args
          result = %w(--detach)
          result << "--volume #{@socket}:/var/run/docker.sock:ro"
          result << "--restart always"
          result << "--publish #{@publish}"
          result << "--net #{@net}"
          result << "--name #{@name}"
          result.join(' ')
        end
      end

      class Down < Dip::Command
        def initialize(name:)
          @name = name
        end

        def execute
          subshell("docker", "stop #{@name}".shellsplit, panic: false, out: File::NULL, err: File::NULL)
          subshell("docker", "rm -v #{@name}".shellsplit, panic: false, out: File::NULL, err: File::NULL)
        end
      end

      class IP < Dip::Command
        def initialize(name:, net:)
          @name = name
          @net = net
        end

        def execute(**options)
          subshell("docker",
                   "inspect " \
                   "--format '{{ .NetworkSettings.Networks.#{@net}.IPAddress }}' " \
                   "#{@name}".shellsplit,
                   **options)
        end
      end
    end
  end
end
