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
            export DIP_SHELL=1
            export DIP_EARLY_ENVS=#{ENV.keys.join(',')}
            export DIP_PROMPT_TEXT="ⅆ"

            function dip_clear() {
              # just stub, will be redefined after injecting aliases
              true
            }

            function dip_inject() {
              eval "$(#{Dip.bin_path} console inject)"
            }

            function dip_reload() {
              dip_clear
              dip_inject
            }

            # Inspired by RVM
            function __zsh_like_cd() {
              \\typeset __zsh_like_cd_hook
              if
                builtin "$@"
              then
                for __zsh_like_cd_hook in chpwd "${chpwd_functions[@]}"
                do
                  if \\typeset -f "$__zsh_like_cd_hook" >/dev/null 2>&1
                  then "$__zsh_like_cd_hook" || break # finish on first failed hook
                  fi
                done
                true
              else
                return $?
              fi
            }

            [[ -n "${ZSH_VERSION:-}" ]] ||
            {
              function cd()    { __zsh_like_cd cd    "$@" ; }
              function popd()  { __zsh_like_cd popd  "$@" ; }
              function pushd() { __zsh_like_cd pushd "$@" ; }
            }

            export -a chpwd_functions
            [[ " ${chpwd_functions[*]} " == *" dip_reload "* ]] || chpwd_functions+=(dip_reload)

            if [[ "$ZSH_THEME" = "agnoster" ]]; then
              eval "`declare -f prompt_end | sed '1s/.*/_&/'`"

              function prompt_end() {
                if [[ -n $DIP_PROMPT_TEXT ]]; then
                  prompt_segment magenta white "$DIP_PROMPT_TEXT"
                fi

                _prompt_end
              }
            fi

            dip_reload
          SH
        end
      end

      class Inject < Dip::Command
        attr_reader :out, :aliases

        def initialize
          @aliases = []
          @out = []
        end

        def execute
          if Dip.config.exist?
            add_aliases(*Dip.config.interaction.keys) if Dip.config.interaction
            add_aliases("compose", "up", "stop", "down", "provision", "build")
          end

          clear_aliases

          puts out.join("\n\n")
        end

        private

        def add_aliases(*names)
          names.each do |name|
            aliases << name
            out << "function #{name}() { #{Dip.bin_path} #{name} $@; }"
          end
        end

        def clear_aliases
          out << "function dip_clear() { \n" \
                  "#{aliases.any? ? aliases.map { |a| "  unset -f #{a}" }.join("\n") : 'true'} " \
                  "\n}"
        end
      end
    end
  end
end
