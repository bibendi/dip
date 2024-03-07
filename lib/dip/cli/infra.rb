# frozen_string_literal: true

require "thor"
require_relative "base"
require_relative "../commands/infra"
require_relative "../commands/infra/service"

module Dip
  class CLI
    class Infra < Base
      desc "update", "Pull infra services updates"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option :name, aliases: "-n", type: :array, default: [],
        desc: "Update infra service, all if empty"
      def update
        if options[:help]
          invoke :help, ["update"]
        else
          lookup_services(options[:name]).each do |service|
            Commands::Infra::Update.new(service: service).execute
          end
        end
      end

      desc "up", "Run infra services"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option :name, aliases: "-n", type: :array, default: [],
        desc: "Start specific infra service, all if empty"
      method_option :update, type: :boolean, default: true,
        desc: "Pull infra services updates"
      def up(*compose_argv)
        if options[:help]
          invoke :help, ["up"]
        else
          lookup_services(options[:name]).each do |service|
            if options[:update]
              Commands::Infra::Update.new(service: service).execute
            end

            Commands::Infra::Up.new(*compose_argv, service: service).execute
          end
        end
      end

      desc "down", "Stop infra services"
      method_option :help, aliases: "-h", type: :boolean,
        desc: "Display usage information"
      method_option :name, aliases: "-n", type: :array, default: [],
        desc: "Stop specific infra service, all if empty"
      def down(*compose_argv)
        if options[:help]
          invoke :help, ["down"]
        else
          lookup_services(options[:name]).each do |service|
            Commands::Infra::Down.new(*compose_argv, service: service).execute
          end
        end
      end

      private

      def lookup_services(names)
        names = Array(names).map(&:to_sym)

        Dip.config.infra.each_with_object([]) do |(name, params), memo|
          next if !names.empty? && !names.include?(name)
          memo << Commands::Infra::Service.new(name, **params)
        end
      end
    end
  end
end
