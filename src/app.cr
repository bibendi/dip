require "./dip.cr"

argv = ARGV.dup

if argv.any? && !%w(compose run ssh dns provision version --help).includes?(argv[0])
  argv = %w(run) + argv
end

exit_status = Dip::Cli.run(argv)
exit exit_status.exit_code if exit_status
