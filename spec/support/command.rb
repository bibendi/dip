def expected_exec(cmd, *argv, env: {})
  expect(Process).to have_received(:exec).with(env, cmd, *argv)
end
