# frozen_string_literal: true

require 'thor'

module Dip
  class CLI < Thor
    class << self
      # Hackery. Take the run method away from Thor so that we can redefine it.
      def is_thor_reserved_word?(word, type)
        return false if word == "run"

        super
      end

      def start(argv)
        super Dip::RunVars.call(argv, ENV)
      end
    end

    stop_on_unknown_option! :up

    def method_missing(cmd, *args)
      if Dip.config.interaction.key?(cmd.to_sym)
        args.unshift(cmd.to_s)
        args.unshift("run")
        self.class.start(args)
      else
        super
      end
    end

    def respond_to_missing?(cmd)
      Dip.config.interaction.key?(cmd.to_sym)
    end

    desc 'version', 'dip version'
    def version
      require_relative 'version'
      puts Dip::VERSION
    end
    map %w(--version -v) => :version

    desc 'compose CMD [OPTIONS]', 'Run docker-compose commands'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def compose(cmd, *argv)
      if options[:help]
        invoke :help, ['compose']
      else
        require_relative 'commands/compose'
        Dip::Commands::Compose.new(cmd, argv).execute
      end
    end

    desc "up [OPTIONS] SERVICE", "Run docker-compose up command"
    def up(*argv)
      compose("up", *argv)
    end

    desc "down [OPTIONS]", "Run docker-compose down command"
    def down(*argv)
      compose("down", *argv)
    end

    desc 'CMD or dip run CMD [OPTIONS]', 'Run configured command in a docker-compose service'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def run(cmd, subcmd = nil, *argv)
      if options[:help]
        invoke :help, ['run']
      else
        require_relative 'commands/run'
        Dip::Commands::Run.new(cmd, subcmd, argv).execute
      end
    end

    desc "provision", "Execute commands within provision section"
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    def provision
      if options[:help]
        invoke :help, ['provision']
      else
        require_relative 'commands/provision'
        Dip::Commands::Provision.new.execute
      end
    end

    require_relative 'cli/ssh'
    desc "ssh", "ssh-agent container commands"
    subcommand :ssh, Dip::CLI::SSH

    require_relative 'cli/dns'
    desc "dns", "DNS server for automatic docker container discovery"
    subcommand :dns, Dip::CLI::DNS

    require_relative 'cli/nginx'
    desc "nginx", "Nginx reverse proxy server"
    subcommand :nginx, Dip::CLI::Nginx

    require_relative 'cli/console'
    desc "console", "Integrate Dip commands into shell (only ZSH is supported now)"
    subcommand :console, Dip::CLI::Console
  end
end
