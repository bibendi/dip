# frozen_string_literal: true

require "shellwords"
require_relative "../command"

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
          exec_subprocess("docker", "network create #{@net}", panic: false, err: File::NULL)
          exec_subprocess("docker", "run #{container_args} #{@image} --domain=#{@domain}")
        end

        private

        def container_args
          result = %w[--detach]
          result << "--volume #{@socket}:/var/run/docker.sock:ro"
          result << "--restart always"
          result << "--publish #{@publish}"
          result << "--net #{@net}"
          result << "--name #{@name}"
          result.join(" ")
        end
      end

      class Down < Dip::Command
        def initialize(name:)
          @name = name
        end

        def execute
          exec_subprocess("docker", "stop #{@name}", panic: false, out: File::NULL, err: File::NULL)
          exec_subprocess("docker", "rm -v #{@name}", panic: false, out: File::NULL, err: File::NULL)
        end
      end

      class IP < Dip::Command
        def initialize(name:, net:)
          @name = name
          @net = net
        end

        def execute(**options)
          exec_subprocess(
            "docker",
            "inspect --format '{{ .NetworkSettings.Networks.#{@net}.IPAddress }}' #{@name}",
            **options
          )
        end
      end
    end
  end
end
