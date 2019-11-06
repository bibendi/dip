# frozen_string_literal: true

require 'thor'
require_relative "../commands/nginx"

module Dip
  class CLI
    # See more https://github.com/bibendi/nginx-proxy
    class Nginx < Thor
      desc "up", "Run nginx container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :name, aliases: '-n', type: :string, default: "nginx",
                           desc: 'Container name'
      method_option :socket, aliases: '-s', type: :string, default: "/var/run/docker.sock",
                             desc: 'Path to docker socket'
      method_option :net, aliases: '-t', type: :string, default: "frontend",
                          desc: 'Container network name'
      method_option :publish, aliases: '-p', type: :array, default: "80:80",
                              desc: 'Container port(s). For more than one port, separate them by a space'
      method_option :image, aliases: '-i', type: :string, default: "bibendi/nginx-proxy:latest",
                            desc: 'Docker image name'
      method_option :domain, aliases: '-d', type: :string, default: "docker",
                             desc: 'Top level domain'
      method_option :certs, aliases: '-c', type: :string, desc: 'Path to ssl certificates'
      def up
        if options[:help]
          invoke :help, ['up']
        else
          Dip::Commands::Nginx::Up.new(
            name: options.fetch(:name),
            socket: options.fetch(:socket),
            net: options.fetch(:net),
            publish: options.fetch(:publish),
            image: options.fetch(:image),
            domain: options.fetch(:domain),
            certs: options[:certs]
          ).execute
        end
      end

      desc "down", "Stop nginx container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :name, aliases: '-n', type: :string, default: "nginx",
                           desc: 'Container name'
      def down
        if options[:help]
          invoke :help, ['down']
        else
          Dip::Commands::Nginx::Down.new(
            name: options.fetch(:name)
          ).execute
        end
      end

      desc "restart", "Stop and start nginx container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def restart(*args)
        if options[:help]
          invoke :help, ['restart']
        else
          Dip::CLI::Nginx.start(["down"] + args)
          sleep 1
          Dip::CLI::Nginx.start(["up"] + args)
        end
      end
    end
  end
end
