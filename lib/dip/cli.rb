# frozen_string_literal: true

require 'thor'

module Dip
  class CLI < Thor
    class << self
      def retrieve_command_name(args)
        meth = args.first.to_sym unless args.empty?
        args.unshift("run") if ::Dip.config.interaction.key?(meth.to_sym) if meth

        super(args)
      end

      # Hackery. Take the run method away from Thor so that we can redefine it.
      def is_thor_reserved_word?(word, type)
        return false if word == "run"
        super
      end
    end

    desc 'version', 'dip version'
    def version
      require_relative 'version'
      puts "#{Dip::VERSION}"
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

    desc 'CMD or dip run CMD [OPTIONS]', 'Run configured command in a docker-compose service'
    method_option :help, aliases: '-h', type: :boolean,
                         desc: 'Display usage information'
    method_option :x_dip_run_vars, type: :hash,
                  desc: "Enforce environment variables into container, recommended run like 'dip FOO=bar cmd'"
    def run(cmd, subcmd = nil, *argv)
      if options[:help]
        invoke :help, ['run']
      else
        require_relative 'commands/run'
        Dip::Commands::Run.
          new(cmd, subcmd, argv,
              run_vars: options[:x_dip_run_vars]).
          execute
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

    desc "ssh", "ssh-agent container commands"
    def ssh(*args)
      require_relative 'cli/ssh'
      Dip::CLI::SSH.start(args)
    end

    desc "dns", "DNS server for automatic docker container discovery"
    def dns(*args)
      require_relative 'cli/dns'
      Dip::CLI::DNS.start(args)
    end

    desc "nginx", "Nginx reverse proxy server"
    def nginx(*args)
      require_relative 'cli/nginx'
      Dip::CLI::Nginx.start(args)
    end
  end
end
