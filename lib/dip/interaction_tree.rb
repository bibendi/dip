# frozen_string_literal: true

require "shellwords"
require "dip/ext/hash"

using ActiveSupportHashHelpers

module Dip
  class InteractionTree
    def initialize(entries)
      @entries = entries
    end

    def find(name, *argv)
      entry = entries[name.to_sym]
      return unless entry

      commands = expand(name.to_s, entry)

      keys = [name, *argv]
      rest = []

      keys.size.times do
        if (command = commands[keys.join(" ")])
          return {command: command, argv: rest.reverse!}
        else
          rest << keys.pop
        end
      end

      nil
    end

    def list
      entries.each_with_object({}) do |(name, entry), memo|
        expand(name.to_s, entry, tree: memo)
      end
    end

    private

    attr_reader :entries

    def expand(name, entry, tree: {})
      cmd = build_command(entry)

      tree[name] = cmd
      base_cmd = entry.select { |k, _| k != :subcommands }

      entry[:subcommands]&.each do |sub_name, sub_entry|
        sub_command_defaults!(sub_entry)
        expand("#{name} #{sub_name}", base_cmd.deep_merge(sub_entry), tree: tree)
      end

      tree
    end

    def build_command(entry)
      {
        description: entry[:description],
        runner: entry[:runner],
        service: entry[:service],
        workdir: entry[:workdir],
        user: entry[:user],
        pod: entry[:pod],
        entrypoint: entry[:entrypoint],
        command: entry[:command].to_s.strip,
        shell: entry.fetch(:shell, true),
        default_args: entry[:default_args].to_s.strip,
        environment: entry[:environment] || {},
        compose: {
          # method: entry.dig(:compose, :method) || entry[:compose_method] || "run",
          method: entry.dig(:compose, :method) || entry[:compose_method] || "exec",
          profiles: Array(entry.dig(:compose, :profiles)),
          run_options: compose_run_options(entry.dig(:compose, :run_options) || entry[:compose_run_options])
        }
      }
    end

    def sub_command_defaults!(entry)
      entry[:command] ||= nil
      entry[:default_args] ||= nil
      entry[:subcommands] ||= nil
      entry[:description] ||= nil
    end

    def compose_run_options(value)
      return [] unless value

      value.map do |o|
        o = o.start_with?("-") ? o : "--#{o}"
        o.shellsplit
      end.flatten
    end
  end
end
