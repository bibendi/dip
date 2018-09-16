shared_context "dip command", runner: true do
  let(:exec_runner) { spy("exec runner") }
  let(:subshell_runner) { spy("subshell runner") }

  before do
    stub_const("Dip::Command::ExecRunner", exec_runner)
    stub_const("Dip::Command::SubshellRunner", subshell_runner)
  end
end


def expected_exec(cmd, *argv, env: {})
  expect(exec_runner).to have_received(:call).with(env, cmd, *argv)
end

def expected_subshell(cmd, *argv, env: {})
  expect(subshell_runner).to have_received(:call).with(env, cmd, *argv)
end
