require "../config_command"

module Dip::Cli::Commands
  class Compose < ::Dip::ConfigCommand
    class Options
      arg "cmd", stop: true,
                 complete: %w(build down exec kill logs pause ps restart rm run scale start stop top unpause up)
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
      compose_args = find_files + find_project_name
      compose_args << args.cmd
      compose_args += unparsed_args

      exec_cmd!("docker-compose", compose_args)
    end

    private def find_files
      result = %w()
      return result unless (config = @config)

      if (files = config.files).is_a?(Array)
        files.each do |file_name|
          file_name = ::Dip.env.replace(file_name)
          result << "--file #{file_name}" if File.exists?(file_name)
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
  end
end
