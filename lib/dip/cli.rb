# frozen_string_literal: true

require "thor"
require "dip/run_vars"

module Dip
  class CLI < Thor
    TOP_LEVEL_COMMANDS = %w[help version ls compose up stop down run provision ssh infra console].freeze

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

        super(Dip::RunVars.call(argv, ENV))
      end
    end

    stop_on_unknown_option! :run, :ktl

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

    desc "compose CMD [OPTIONS]", "Run Docker Compose commands"
    def compose(*argv)
      require_relative "commands/compose"
      Dip::Commands::Compose.new(*argv).execute
    end

    desc "build [OPTIONS] SERVICE", "Run `docker compose build` command"
    def build(*argv)
      compose("build", *argv)
    end

    desc "up [OPTIONS] SERVICE", "Run `docker compose up` command"
    def up(*argv)
      compose("up", *argv)
    end

    desc "stop [OPTIONS] SERVICE", "Run `docker compose stop` command"
    def stop(*argv)
      compose("stop", *argv)
    end

    desc "down [OPTIONS]", "Run `docker compose down` command"
    method_option :help, aliases: "-h", type: :boolean, desc: "Display usage information"
    method_option :all, aliases: "-A", type: :boolean, desc: "Shutdown all running Docker Compose projects"
    def down(*argv)
      if options[:help]
        invoke :help, ["down"]
      elsif options[:all]
        require_relative "commands/down_all"
        Dip::Commands::DownAll.new.execute
      else
        compose("down", *argv.push("--remove-orphans"))
      end
    end

    desc "ktl CMD [OPTIONS]", "Run kubectl commands"
    def ktl(*argv)
      require_relative "commands/kubectl"
      Dip::Commands::Kubectl.new(*argv).execute
    end

    desc "run [OPTIONS] CMD [ARGS]", "Run configured command (`run` prefix may be omitted)"
    method_option :publish, aliases: "-p", type: :string, repeatable: true,
      desc: "Publish a container's port(s) to the host"
    method_option :help, aliases: "-h", type: :boolean, desc: "Display usage information"
    def run(*argv)
      if argv.empty? || options[:help]
        invoke :help, ["run"]
      else
        require_relative "commands/run"

        Dip::Commands::Run.new(
          *argv,
          **options.to_h.transform_keys!(&:to_sym)
        ).execute
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

    require_relative "cli/infra"
    desc "infra", "Infrastructure services"
    subcommand :infra, Dip::CLI::Infra

    require_relative "cli/console"
    desc "console", "Integrate Dip commands into shell (only ZSH and Bash are supported)"
    subcommand :console, Dip::CLI::Console
  end
end
