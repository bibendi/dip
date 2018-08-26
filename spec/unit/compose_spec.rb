require 'dip/commands/compose'

RSpec.describe Dip::Commands::Compose do
  it "executes `compose` command successfully" do
    command = Dip::Commands::Compose.new("cmd", %w(-arg1 --arg2 val))

    expect(command).to receive(:command).with("docker-compose", "cmd", "-arg1", "--arg2", "val", anything)
    command.execute
  end

  it "finds project name" do
    dip_config(compose: {project_name: "test-app"})
    command = Dip::Commands::Compose.new("cmd")

    expect(command).to receive(:command).with("docker-compose", "--project-name", "test-app", "cmd", anything)
    command.execute
  end

  it "finds files", fakefs: true do
    dip_config(compose: {files: %w(docker-compose.yml docker-compose.test.yml docker-compose.fake.yml)})
    File.write("docker-compose.yml", '--')
    File.write("docker-compose.test.yml", '--')
    command = Dip::Commands::Compose.new("cmd")

    expect(command).
      to receive(:command).
      with("docker-compose", "--file", "docker-compose.yml", "--file", "docker-compose.test.yml", "cmd", anything)
    command.execute
  end
end
