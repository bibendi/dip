# frozen_string_literal: true

require_relative "base"
require_relative "../../command"

module Dip
  module Commands
    module Runners
      class LocalRunner < Base
        def execute
          Dip::Command.exec_program(
            command[:command],
            command_args,
            shell: command[:shell]
          )
        end
      end
    end
  end
end
