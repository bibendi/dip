# frozen_string_literal: true

require 'thor'
require_relative "./base"
require_relative "../commands/dns"

module Dip
  class CLI
    # See more https://github.com/aacebedo/dnsdock
    class DNS < Base
      desc "up", "Run dnsdock container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :name, aliases: '-n', type: :string, default: "dnsdock",
                           desc: 'Container name'
      method_option :socket, aliases: '-s', type: :string, default: "/var/run/docker.sock",
                             desc: 'Path to docker socket'
      method_option :net, aliases: '-t', type: :string, default: "frontend",
                          desc: 'Container network name'
      method_option :publish, aliases: '-p', type: :string, default: "53/udp",
                              desc: 'Container port'
      method_option :image, aliases: '-i', type: :string, default: "aacebedo/dnsdock:latest-amd64",
                            desc: 'Docker image name'
      method_option :domain, aliases: '-d', type: :string, default: "docker",
                             desc: 'Top level domain'
      def up
        if options[:help]
          invoke :help, ['up']
        else
          Dip::Commands::DNS::Up.new(
            name: options.fetch(:name),
            socket: options.fetch(:socket),
            net: options.fetch(:net),
            publish: options.fetch(:publish),
            image: options.fetch(:image),
            domain: options.fetch(:domain)
          ).execute
        end
      end

      desc "down", "Stop dnsdock container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :name, aliases: '-n', type: :string, default: "dnsdock",
                           desc: 'Container name'
      def down
        if options[:help]
          invoke :help, ['down']
        else
          Dip::Commands::DNS::Down.new(
            name: options.fetch(:name)
          ).execute
        end
      end

      desc "restart", "Stop and start dnsdock container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def restart(*args)
        if options[:help]
          invoke :help, ['restart']
        else
          Dip::CLI::DNS.start(["down"] + args)
          sleep 1
          Dip::CLI::DNS.start(["up"] + args)
        end
      end

      desc "ip", "Get ip address of dnsdock container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :name, aliases: '-n', type: :string, default: "dnsdock",
                           desc: 'Container name'
      method_option :net, aliases: '-t', type: :string, default: "frontend",
                          desc: 'Container network name'
      def ip
        if options[:help]
          invoke :help, ['status']
        else
          Dip::Commands::DNS::IP.new(
            name: options.fetch(:name),
            net: options.fetch(:net)
          ).execute
        end
      end
    end
  end
end
