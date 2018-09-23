shared_context "dip command", runner: true do
  let(:exec_runner) { spy("exec runner") }
  let(:subshell_runner) { spy("subshell runner") }

  before do
    stub_const("Dip::Command::ExecRunner", exec_runner)
    stub_const("Dip::Command::SubshellRunner", subshell_runner)
  end
end


def expected_exec(cmd, argv, env: kind_of(Hash))
  argv = Array(argv) if argv.is_a?(String)
  expect(exec_runner).to have_received(:call).with(cmd, argv, env: env)
end

def expected_subshell(cmd, argv, env: kind_of(Hash))
  argv = Array(argv) if argv.is_a?(String)
  expect(subshell_runner).to have_received(:call).with(cmd, argv, env: env)
end
