# frozen_string_literal: true

require_relative "../command"

module Dip
  module Commands
    module Console
      # Interaction command names come straight from `dip.yml`, and `inject`
      # turns each one into a same-named shell function. A name that collides
      # with a shell builtin/keyword silently shadows it for the rest of the
      # session — e.g. an interaction called `jobs` breaks `jobs`, which
      # things like Starship's prompt call on every render, turning every
      # keystroke into a `dip jobs` invocation. Skip those instead of
      # aliasing over them.
      RESERVED_NAMES = %w[
        cd pwd test read set jobs type command builtin history alias unalias
        source eval exec exit return break continue trap kill wait bg fg
        export unset declare typeset readonly local shift times true false
        echo printf time status functions function end
      ].freeze

      # Figure out which shell dialect to generate integration code for.
      #
      # An explicit value (from `--shell`) always wins. Otherwise we guess from
      # the `$SHELL` environment variable and fall back to the POSIX flavour
      # (bash/zsh) which was the only supported one historically.
      def self.detect_shell(explicit = nil)
        name = (explicit || File.basename(ENV["SHELL"].to_s)).to_s.downcase
        name.include?("fish") ? :fish : :posix
      end

      class Start < Dip::Command
        def initialize(shell: nil)
          @shell = Console.detect_shell(shell)
        end

        def execute
          puts fish? ? fish_script : posix_script
        end

        private

        def fish?
          @shell == :fish
        end

        def inject_command
          "#{Dip.bin_path} console inject --shell #{@shell}"
        end

        def posix_script
          <<-SH.gsub(/^ {12}/, "")
            export DIP_SHELL=1
            export DIP_EARLY_ENVS=#{ENV.keys.join(",")}
            export DIP_PROMPT_TEXT="ⅆ"

            function dip_clear() {
              # just stub, will be redefined after injecting aliases
              true
            }

            function dip_inject() {
              eval "$(#{inject_command})"
            }

            function dip_reload() {
              dip_clear
              dip_inject
            }

            # Resolves the dip.yml that applies to $PWD (or $DIP_FILE), without
            # spawning a `dip` process — used to skip redundant reloads below.
            function __dip_config_path() {
              if [ -n "${DIP_FILE:-}" ]; then
                printf '%s\\n' "$DIP_FILE"
                return
              fi

              \\typeset __dip_dir="$PWD"
              while :; do
                if [ -e "$__dip_dir/dip.yml" ]; then
                  printf '%s\\n' "$__dip_dir/dip.yml"
                  return
                fi
                [ "$__dip_dir" = "/" ] && return
                __dip_dir=$(dirname "$__dip_dir")
              done
            }

            # Only reload aliases on `cd` when the resolved dip.yml actually
            # changed — most `cd`s stay within the same project and would
            # otherwise re-spawn `dip` (Ruby boot + schema validation) for nothing.
            function __dip_auto_reload() {
              \\typeset __dip_new_config_path
              __dip_new_config_path="$(__dip_config_path)"
              [ "$__dip_new_config_path" = "${__DIP_CONFIG_PATH:-}" ] && return
              __DIP_CONFIG_PATH="$__dip_new_config_path"
              dip_reload
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
            [[ " ${chpwd_functions[*]} " == *" __dip_auto_reload "* ]] || chpwd_functions+=(__dip_auto_reload)

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
            __DIP_CONFIG_PATH="$(__dip_config_path)"
          SH
        end

        def fish_script
          <<-FISH.gsub(/^ {12}/, "")
            set -gx DIP_SHELL 1
            set -gx DIP_EARLY_ENVS "#{ENV.keys.join(",")}"
            set -gx DIP_PROMPT_TEXT "ⅆ"

            function dip_clear
              # just stub, will be redefined after injecting aliases
              true
            end

            function dip_inject
              #{inject_command} | source
            end

            function dip_reload
              dip_clear
              dip_inject
            end

            # Resolves the dip.yml that applies to $PWD (or $DIP_FILE), without
            # spawning a `dip` process — used to skip redundant reloads below.
            function __dip_config_path
              if set -q DIP_FILE
                echo "$DIP_FILE"
                return
              end

              set -l __dip_dir "$PWD"
              while true
                if test -e "$__dip_dir/dip.yml"
                  echo "$__dip_dir/dip.yml"
                  return
                end
                if test "$__dip_dir" = "/"
                  return
                end
                set __dip_dir (dirname "$__dip_dir")
              end
            end

            # Renew aliases whenever the working directory changes — but only
            # when the resolved dip.yml actually changed. Most `cd`s stay within
            # the same project and would otherwise re-spawn `dip` (Ruby boot +
            # schema validation) for nothing.
            function __dip_chpwd --on-variable PWD
              set -l __dip_new_config_path (__dip_config_path)
              if test "$__dip_new_config_path" != "$__dip_config_path_cache"
                set -g __dip_config_path_cache "$__dip_new_config_path"
                dip_reload
              end
            end

            dip_reload
            set -g __dip_config_path_cache (__dip_config_path)
          FISH
        end
      end

      class Inject < Dip::Command
        attr_reader :out, :aliases

        def initialize(shell: nil)
          @shell = Console.detect_shell(shell)
          @aliases = []
          @out = []
        end

        def execute
          # Runs on every automatic shell reload (e.g. on `cd`), so it only needs
          # the interaction command names, not full schema conformance — skip the
          # `json-schema` require and validation pass that every other command pays.
          with_validation_skipped do
            if Dip.config.exist?
              add_aliases(*Dip.config.interaction.keys) if Dip.config.interaction
              add_aliases("compose", "up", "stop", "down", "provision", "build")
            end
          end

          clear_aliases

          puts out.join("\n\n")
        end

        private

        def with_validation_skipped
          had_key = ENV.key?("DIP_SKIP_VALIDATION")
          previous = ENV["DIP_SKIP_VALIDATION"]
          ENV["DIP_SKIP_VALIDATION"] = "1"
          yield
        ensure
          if had_key
            ENV["DIP_SKIP_VALIDATION"] = previous
          else
            ENV.delete("DIP_SKIP_VALIDATION")
          end
        end

        def fish?
          @shell == :fish
        end

        def add_aliases(*names)
          names.each do |name|
            if Console::RESERVED_NAMES.include?(name.to_s)
              warn "dip: skipping alias `#{name}` — it would shadow the `#{name}` shell builtin. " \
                "Run it as `#{Dip.bin_path} #{name}`, or rename it in dip.yml."
              next
            end

            aliases << name
            out << if fish?
              "function #{name}; #{Dip.bin_path} #{name} $argv; end"
            else
              "function #{name}() { #{Dip.bin_path} #{name} $@; }"
            end
          end
        end

        def clear_aliases
          out << if fish?
            body = aliases.any? ? "functions -e #{aliases.join(" ")}" : "true"
            "function dip_clear; #{body}; end"
          else
            "function dip_clear() { \n" \
              "#{aliases.any? ? aliases.map { |a| "  unset -f #{a}" }.join("\n") : "true"} " \
              "\n}"
          end
        end
      end
    end
  end
end
