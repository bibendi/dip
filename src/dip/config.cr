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
        environment: {
          type: Hash(String, String | Bool | Int64 | Float64 | String | Time),
          default: Hash(String, String | Bool | Int64 | Float64 | String | Time).new
        },
        command: {
          type: String,
          nilable: true
        },
        compose_method: {
          type: String,
          default: "run"
        }
      )
    end

    class Command
      YAML.mapping(
        service: {
          type: String,
        },
        environment: {
          type: Hash(String, String | Bool | Int64 | Float64 | String | Time),
          default: Hash(String, String | Bool | Int64 | Float64 | String | Time).new
        },
        command: {
          type: String,
          nilable: true
        },
        subcommands: {
          type: Hash(String, ::Dip::Config::Subcommand),
          nilable: true
        },
        compose_run_options: {
          type: Array(String),
          nilable: true
        },
        compose_method: {
          type: String,
          default: "run"
        }
      )
    end

    YAML.mapping(
      version: {
        type: String
      },
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
