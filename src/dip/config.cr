require "yaml"

module Dip
  class Config
    class Compose
      YAML.mapping(
        files: {
          type: Array(String),
          nilable: true
        },
        project_name: {
          type: String,
          nilable: true
        }
      )
    end

    class Subcommand
      YAML.mapping(
        service: {
          type: String,
          nilable: true
        },
        command: {
          type: String,
          nilable: true
        }
      )
    end

    class Command
      YAML.mapping(
        service: {
          type: String,
        },
        command: {
          type: String,
          nilable: true
        },
        subcommands: {
          type: Hash(String, ::Dip::Config::Subcommand),
          nilable: true
        }
      )
    end

    YAML.mapping(
      environment: {
        type: Hash(String, String),
        default: Hash(String, String).new
      },
      compose: {
        type: ::Dip::Config::Compose,
        nilable: true
      },
      interaction: {
        type: Hash(String, ::Dip::Config::Command),
        nilable: true
      },
      provision: {
        type: Array(String),
        nilable: true
      }
    )
  end
end
