# frozen_string_literal: true

require "thor"
require "dip/run_vars"

module Dip
  class CLI < Thor
    TOP_LEVEL_COMMANDS = %w[help version ls compose up stop down run provision ssh dns nginx console].freeze

    class << self
      # Hackery. Take the run method away from Thor so that we can redefine it.
      def is_thor_reserved_word?(word, type)
        return false if word == "run"

        super
      end

      def exit_on_failure?
        true
      end

      def start(argv)
        argv = Dip::RunVars.call(argv, ENV)

        cmd = argv.first

        if cmd && !TOP_LEVEL_COMMANDS.include?(cmd) && Dip.config.exist? && Dip.config.interaction.key?(cmd.to_sym)
          argv.unshift("run")
        end

        super Dip::RunVars.call(argv, ENV)
      end
    end

    stop_on_unknown_option! :run

    desc "version", "dip version"
    def version
      require_relative "version"
      puts Dip::VERSION
    end
    map %w[--version -v] => :version

    desc "ls", "List available run commands"
    def ls
      require_relative "commands/list"
      Dip::Commands::List.new.execute
    end

    desc "compose CMD [OPTIONS]", "Run docker-compose commands"
    def compose(*argv)
      require_relative "commands/compose"
      Dip::Commands::Compose.new(*argv).execute
    end

    desc "build [OPTIONS] SERVICE", "Run `docker-compose build` command"
    def build(*argv)
      compose("build", *argv)
    end

    desc "up [OPTIONS] SERVICE", "Run `docker-compose up` command"
    def up(*argv)
      compose("up", *argv)
    end

    desc "stop [OPTIONS] SERVICE", "Run `docker-compose stop` command"
    def stop(*argv)
      compose("stop", *argv)
    end

    desc "down [OPTIONS]", "Run `docker-compose down` command"
    def down(*argv)
      compose("down", *argv)
    end

    desc "run [OPTIONS] CMD [ARGS]", "Run configured command in a docker-compose service. `run` prefix may be omitted"
    method_option :publish, aliases: "-p", type: :string, repeatable: true,
      desc: "Publish a container's port(s) to the host"
    method_option :help, aliases: "-h", type: :boolean, desc: "Display usage information"
    def run(*argv)
      if argv.empty? || options[:help]
        invoke :help, ["run"]
      else
        require_relative "commands/run"
        Dip::Commands::Run.new(*argv, publish: options[:publish]).execute
      end
    end

    desc "provision", "Execute commands within provision section"
    method_option :help, aliases: "-h", type: :boolean,
      desc: "Display usage information"
    def provision
      if options[:help]
        invoke :help, ["provision"]
      else
        require_relative "commands/provision"
        Dip::Commands::Provision.new.execute
      end
    end

    require_relative "cli/ssh"
    desc "ssh", "ssh-agent container commands"
    subcommand :ssh, Dip::CLI::SSH

    require_relative "cli/dns"
    desc "dns", "DNS server for automatic docker container discovery"
    subcommand :dns, Dip::CLI::DNS

    require_relative "cli/nginx"
    desc "nginx", "Nginx reverse proxy server"
    subcommand :nginx, Dip::CLI::Nginx

    require_relative "cli/console"
    desc "console", "Integrate Dip commands into shell (only ZSH and Bash are supported)"
    subcommand :console, Dip::CLI::Console
  end
end
