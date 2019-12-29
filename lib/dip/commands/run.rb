# frozen_string_literal: true

require 'shellwords'
require_relative '../../../lib/dip/run_vars'
require_relative '../command'
require_relative '../interaction_tree'
require_relative 'compose'

module Dip
  module Commands
    class Run < Dip::Command
      def initialize(cmd, *argv)
        @command, @argv = InteractionTree.
                          new(Dip.config.interaction).
                          find(cmd, *argv)&.
                          values_at(:command, :argv)

        raise Dip::Error, "Command `#{[cmd, *argv].join(' ')}` not recognized!" unless command

        Dip.env.merge(command[:environment])
      end

      def execute
        Dip::Commands::Compose.new(
          command[:compose][:method],
          *compose_arguments
        ).execute
      end

      private

      attr_reader :command, :argv

      def compose_arguments
        compose_argv = command[:compose][:run_options].dup

        if command[:compose][:method] == "run"
          compose_argv.concat(run_vars)
          compose_argv << "--rm"
        end

        compose_argv << command.fetch(:service)

        unless (cmd = command[:command].to_s).empty?
          compose_argv.concat(cmd.shellsplit)
        end

        compose_argv.concat(argv.any? ? argv : command[:default_args])

        compose_argv
      end

      def run_vars
        run_vars = Dip::RunVars.env
        return [] unless run_vars

        run_vars.map { |k, v| ["-e", "#{k}=#{v}"] }.flatten
      end
    end
  end
end
