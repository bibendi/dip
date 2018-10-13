# frozen_string_literal: true

require_relative '../command'

module Dip
  module Commands
    module Console
      class Start < Dip::Command
        def execute
          puts script
        end

        private

        def script
          <<-SH.gsub(/^[ ]{12}/, '')
            if [ "$DIP_SHELL" != "1" ]; then
              export DIP_SHELL=zsh
              export DIP_EARLY_ENVS=#{ENV.keys.join(',')}
            fi

            function _dip_remove_aliases() {
              # will be redefined
            }

            function _dip_source_aliases() {
              #{Dip.bin_path} console inject | source /dev/stdin
            }

            _dip_source_aliases

            function chpwd() {
              _dip_remove_aliases
              _dip_source_aliases
            }
          SH
        end
      end

      class Inject < Dip::Command
        def initialize
          @aliases = []
          @out = []
        end

        def execute
          if Dip.config.exist?
            alias_interaction if Dip.config.interaction
            alias_compose
            add_alias("provision")
          end

          fill_removing_aliases

          puts @out.join("\n\n")
        end

        private

        def alias_interaction
          Dip.config.interaction.keys.each do |name|
            add_alias(name)
          end
        end

        def alias_compose
          %w(compose up down).each do |name|
            add_alias(name)
          end
        end

        def add_alias(name)
          @aliases << name
          @out << "function #{name}() { #{Dip.bin_path} #{name} $@; }"
        end

        def fill_removing_aliases
          @out << "function _dip_remove_aliases() { \n" \
                  "#{@aliases.map { |a| "  unset -f #{a}" }.join("\n")} " \
                  "\n}"
        end
      end
    end
  end
end
