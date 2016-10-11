require "../command"

module Dip::Cli::Commands
  class Compose < ::Dip::Command
    class Options
      arg "cmd", stop: true
      help
    end

    class Help
      caption "Run docker-compose commands"
    end

    @config : Dip::Config::Compose | Nil

    def initialize(*args)
      super
      @config = ::Dip.config.compose
    end

    def run
      compose_args = find_files + find_project_name + args.values
      compose_args += run_env_args if args.cmd == "run"
      compose_args += unparsed_args

      env = ::Dip.env.vars.map { |key, value| "#{key}=#{value}" }.join(" ")

      exec!("env #{common_env_args.join(" ")} docker-compose", compose_args)
    end

    private def find_files
      result = %w()
      return result unless (config = @config)

      if (files = config.files).is_a?(Array)
        files.each do |file_name|
          file_name = ::Dip.env.replace(file_name)
          result << "--file #{file_name}"
        end
      end

      result
    end

    private def find_project_name
      result = %w()
      return result unless (config = @config)

      if (project_name = config.project_name).is_a?(String)
        project_name = ::Dip.env.replace(project_name)
        result << "--project-name #{project_name}"
      end

      result
    end

    private def common_env_args
      ::Dip.env.vars.map { |key, value| "#{key}=#{value}" }
    end

    private def run_env_args
      ::Dip.env.vars.map { |key, value| "-e #{key}=#{value}" }
    end
  end
end
