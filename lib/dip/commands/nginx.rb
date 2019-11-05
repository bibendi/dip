# frozen_string_literal: true

require "shellwords"
require_relative '../command'

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
          subshell("docker", "network create #{@net}".shellsplit, panic: false, err: File::NULL)
          subshell("docker", "run #{container_args} #{@image}".shellsplit)
        end

        private

        def container_args
          result = %w(--detach)
          result << "--volume #{@socket}:/tmp/docker.sock:ro"
          result << "--volume #{@certs}:/etc/nginx/certs" unless @certs.to_s.empty?
          result << "--restart always"
          result << "#{@publish.split(',').map { |p| "--publish #{p}" }.join(' ')}"
          result << "--net #{@net}"
          result << "--name #{@name}"
          result << "--label com.dnsdock.alias=#{@domain}"
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
    end
  end
end
