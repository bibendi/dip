require "../config_command"

module Dip::Cli::Commands
  class Run < ::Dip::ConfigCommand
    class Options
      arg "cmd", complete: "ruby -ryaml -e 'puts (YAML.load(IO.read(\"dip.yml\"))[\"interaction\"] || {}).keys'"
      arg "subcmd", stop: true, default: ""
      help
    end

    class Help
      caption "Run configured command in a service"
    end

    @config : Hash(String, ::Dip::Config::Command) | Nil

    def initialize(*args)
      super
      @config = ::Dip.config.interaction
    end

    def run
      return unless (config = @config)

      command = config[args.cmd]

      ::Dip.env.merge!(command.environment)

      if subcommands = command.subcommands
        subcommand = subcommands[args.subcmd]
        ::Dip.env.merge!(subcommand.environment)
        service_arg = subcommand.service || command.service
        cmd_arg = subcommand.command
      else
        service_arg = command.service
        cmd_arg = "#{command.command} #{args.subcmd}".strip
      end

      cmd_options = (unparsed_args || %w()).join(" ")

      run_opts = ["rm"]
      if opts = command.compose_run_options
        run_opts.concat(opts)
      end

      run_opts = run_opts.map { |o| "--#{o}" }.join(" ")

      exec_cmd!("#{Process.executable_path} compose run #{run_opts} #{service_arg} #{cmd_arg} #{cmd_options}".strip)
    end
  end
end
