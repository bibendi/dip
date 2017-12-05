require "../config_command"

module Dip::Cli::Commands
  class Run < ::Dip::ConfigCommand
    class Options
      arg "cmd", stop: true, complete: "ruby -ryaml -e 'puts (YAML.load(IO.read(\"dip.yml\"))[\"interaction\"] || {}).keys'"
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

      run_opts = %w()
      cmd_options = unparsed_args || %w()
      first_arg = cmd_options.first unless cmd_options.empty?
      subcommands = command.subcommands

      service_arg = command.service
      compose_method = command.compose_method

      if first_arg && subcommands && subcommands[first_arg]?
        subcommand = subcommands[first_arg]
        cmd_options.shift
        ::Dip.env.merge!(subcommand.environment)
        service_arg = subcommand.service if subcommand.service
        compose_method = subcommand.compose_method if subcommand.compose_method
        cmd_arg = subcommand.command
      else
        cmd_arg = command.command
      end

      run_opts << "rm" if compose_method == "run"

      if opts = command.compose_run_options
        run_opts.concat(opts)
      end

      run_opts = run_opts.map { |o| "--#{o}" }.join(" ")
      cmd_options = cmd_options.join(" ").strip

      exec_cmd!("#{Process.executable_path} compose #{compose_method} #{run_opts} #{service_arg} #{cmd_arg} #{cmd_options}".strip)
    end
  end
end
