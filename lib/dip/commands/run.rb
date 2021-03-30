# frozen_string_literal: true

require 'shellwords'
require_relative '../../../lib/dip/run_vars'
require_relative '../command'
require_relative '../interaction_tree'
require_relative 'compose'

module Dip
  module Commands
    class Run < Dip::Command
      def initialize(cmd, *argv, publish: nil)
        @publish = publish

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

      attr_reader :command, :argv, :publish

      def compose_arguments
        compose_argv = command[:compose][:run_options].dup

        if command[:compose][:method] == "run"
          compose_argv.concat(run_vars)
          compose_argv.concat(published_ports)
          compose_argv << "--rm"
        end

        compose_argv << command.fetch(:service)

        unless (cmd = command[:command]).empty?
          compose_argv << cmd
        end

        if argv.any?
          compose_argv.concat(argv)
        elsif !(default_args = command[:default_args]).empty?
          compose_argv << default_args
        end

        compose_argv
      end

      def run_vars
        run_vars = Dip::RunVars.env
        return [] unless run_vars

        run_vars.map { |k, v| ["-e", "#{k}=#{Shellwords.escape(v)}"] }.flatten
      end

      def published_ports
        if publish.respond_to?(:each)
          publish.map { |p| "--publish=#{p}" }
        else
          []
        end
      end
    end
  end
end
