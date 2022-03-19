# frozen_string_literal: true

require "thor"
require_relative "./base"
require_relative "../commands/console"

module Dip
  class CLI
    class Console < Base
      desc "start", "Integrate Dip into current shell"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      def start
        if options[:help]
          invoke :help, ["start"]
        else
          Dip::Commands::Console::Start.new.execute
        end
      end

      default_task :start

      desc "inject", "Inject aliases"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      def inject
        if options[:help]
          invoke :help, ["inject"]
        else
          Dip::Commands::Console::Inject.new.execute
        end
      end
    end
  end
end
