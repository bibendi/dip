# frozen_string_literal: true

require "thor"
require_relative "./base"
require_relative "../commands/ssh"

module Dip
  class CLI
    class SSH < Base
      desc "up", "Run ssh-agent container"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option :key, aliases: "-k", type: :string, default: "$HOME/.ssh/id_rsa",
        desc: "Path to ssh key"
      method_option :volume, aliases: "-v", type: :string, default: "$HOME",
        desc: "Mounted docker volume"
      method_option :interactive, aliases: "-t", type: :boolean, default: true,
        desc: "Run in interactive mode"
      method_option :user, aliases: "-u", type: :string,
        desc: "UID for ssh-agent container"
      # Backward compatibility
      method_option :nonteractive, aliases: "-T", type: :boolean,
        desc: "Run in noninteractive mode"
      def up
        if options[:help]
          invoke :help, ["up"]
        else
          Dip::Commands::SSH::Up.new(
            key: options.fetch(:key),
            volume: options.fetch(:volume),
            interactive: options.nonteractive? ? false : options.interactive?,
            user: options.user
          ).execute
        end
      end

      map add: :up

      desc "down", "Stop ssh-agent container"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      def down
        if options[:help]
          invoke :help, ["down"]
        else
          Dip::Commands::SSH::Down.new.execute
        end
      end

      desc "restart", "Stop and start ssh-agent container"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      def restart(*args)
        if options[:help]
          invoke :help, ["restart"]
        else
          Dip::CLI::SSH.start(["down"] + args)
          sleep 1
          Dip::CLI::SSH.start(["up"] + args)
        end
      end

      desc "status", "Show status of ssh-agent container"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      def status
        if options[:help]
          invoke :help, ["status"]
        else
          Dip::Commands::SSH::Status.new.execute
        end
      end
    end
  end
end
