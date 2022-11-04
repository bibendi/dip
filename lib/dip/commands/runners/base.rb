# frozen_string_literal: true

module Dip
  module Commands
    module Runners
      class Base
        def initialize(command, argv, **options)
          @command = command
          @argv = argv
          @options = options
        end

        def execute
          raise NotImplementedError
        end

        private

        attr_reader :command, :argv, :options

        def command_args
          if argv.any?
            if command[:shell]
              [argv.shelljoin]
            else
              Array(argv)
            end
          elsif !(default_args = command[:default_args]).empty?
            if command[:shell]
              default_args.shellsplit
            else
              Array(default_args)
            end
          else
            []
          end
        end
      end
    end
  end
end
