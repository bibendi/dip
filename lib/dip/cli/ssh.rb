# frozen_string_literal: true

require 'thor'
require_relative "../commands/ssh"

module Dip
  class CLI
    class SSH < Thor
      desc "ssh up", "Run ssh-agent container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      method_option :key, aliases: '-k', type: :string, default: "$HOME/.ssh/id_rsa",
                          desc: 'Path to ssh key'
      method_option :volume, aliases: '-v', type: :string, default: "$HOME",
                             desc: 'Mounted docker volume'
      method_option :interactive, aliases: '-t', type: :boolean, default: true,
                                  desc: 'Run in interactive mode'
      # Backward compatibility
      method_option :nonteractive, aliases: '-T', type: :boolean,
                                   desc: 'Run in noninteractive mode'
      def up
        if options[:help]
          invoke :help, ['up']
        else
          Dip::Commands::SSH::Up.new(key: options.fetch(:key),
                 volume: options.fetch(:volume),
                 interactive: options.nonteractive? ? false : options.interactive?
          ).execute
        end
      end

      desc "ssh down", "Stop ssh-agent container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def down
        if options[:help]
          invoke :help, ['down']
        else
          Dip::Commands::SSH::Down.new.execute
        end
      end

      desc "ssh restart", "Stop and start ssh-agent container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def restart(*args)
        if options[:help]
          invoke :help, ['restart']
        else
          Dip::CLI::SSH.start(["down"] + args)
          sleep 1
          Dip::CLI::SSH.start(["up"] + args)
        end
      end

      desc "ssh status", "Show status of ssh-agent container"
      method_option :help, aliases: '-h', type: :boolean,
                           desc: 'Display usage information'
      def status
        if options[:help]
          invoke :help, ['status']
        else
          Dip::Commands::SSH::Status.new.execute
        end
      end
    end
  end
end
