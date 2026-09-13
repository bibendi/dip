# frozen_string_literal: true

require "thor"
require_relative "base"
require_relative "../commands/console"

module Dip
  class CLI
    class Console < Base
      SHELL_OPTION = [
        :shell,
        {aliases: "-s", type: :string, enum: %w[bash zsh fish posix],
         desc: "Target shell dialect (autodetected from $SHELL by default)"}
      ].freeze

      desc "start", "Integrate Dip into current shell"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option(*SHELL_OPTION)
      def start
        if options[:help]
          invoke :help, ["start"]
        else
          Dip::Commands::Console::Start.new(shell: options[:shell]).execute
        end
      end

      default_task :start

      desc "inject", "Inject aliases"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option(*SHELL_OPTION)
      def inject
        if options[:help]
          invoke :help, ["inject"]
        else
          Dip::Commands::Console::Inject.new(shell: options[:shell]).execute
        end
      end
    end
  end
end
