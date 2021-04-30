# frozen_string_literal: true

require "shellwords"
require_relative "../command"

module Dip
  module Commands
    module Nginx
      class Up < Dip::Command
        def initialize(name:, socket:, net:, publish:, image:, domain:, certs:)
          @name = name
          @socket = socket
          @net = net
          @publish = publish
          @image = image
          @domain = domain
          @certs = certs
        end

        def execute
          exec_subprocess("docker", "network create #{@net}", panic: false, err: File::NULL)
          exec_subprocess("docker", "run #{container_args} #{@image}")
        end

        private

        def container_args
          result = %w[--detach]
          result << "--volume #{@socket}:/tmp/docker.sock:ro"
          result << "--volume #{@certs}:/etc/nginx/certs" unless @certs.to_s.empty?
          result << "--restart always"
          result << Array(@publish).map { |p| "--publish #{p}" }.join(" ")
          result << "--net #{@net}"
          result << "--name #{@name}"
          result << "--label com.dnsdock.alias=#{@domain}"
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
    end
  end
end
