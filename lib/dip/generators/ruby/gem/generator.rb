# frozen_string_literal: true

module Dip
  class Generator < Thor::Group
    include Thor::Actions

    class_option :ruby, default: "latest"
    class_option :postgres, default: false
    class_option :appraisal, default: false

    def self.source_root
      File.join(__dir__, "templates")
    end

    def create_docker_compose_config
      template("docker-compose.yml.tt", File.join("tmp", "docker-compose.yml"))
    end

    def create_dip_config
      template("dip.yml.tt", File.join("tmp", "dip.yml"))
    end
  end
end
