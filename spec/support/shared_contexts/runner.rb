# frozen_string_literal: true

shared_context "dip command", :runner do
  let(:exec_program_runner) { spy("exec_program runner") }
  let(:exec_subprocess_runner) { spy("exec_subprocess runner") }

  before do
    stub_const("Dip::Command::ProgramRunner", exec_program_runner)
    stub_const("Dip::Command::SubprocessRunner", exec_subprocess_runner)
  end
end

def expected_exec(cmd, argv, options = kind_of(Hash))
  argv = Array(argv) if argv.is_a?(String)
  cmdline = [cmd, *argv].compact.join(" ").strip
  expect(exec_program_runner).to have_received(:call).with(cmdline, options)
end

def expected_subprocess(cmd, argv, options = kind_of(Hash))
  argv = Array(argv) if argv.is_a?(String)
  cmdline = [cmd, *argv].compact.join(" ").strip
  expect(exec_subprocess_runner).to have_received(:call).with(cmdline, options)
end
