require "./dip.cr"

args = %w()
env_var_regexp = /[A-Z]{1}[A-Z0-9_]=/
store_env_vars = true
ARGV.each do |arg|
  if arg =~ env_var_regexp && store_env_vars
    key, val = arg.split("=", limit: 2, remove_empty: true)
    ENV[key] = val
  else
    args << arg
    store_env_vars = false
  end
end

commands = %w(completion compose run ssh dns nginx provision version --help)
args.unshift("run") if args.any? && !commands.includes?(args[0])

exit_status = Dip::Cli.run(args)
exit exit_status.exit_code if exit_status
