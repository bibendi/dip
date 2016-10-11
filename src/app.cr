require "./dip"

argv = ARGV.dup

if argv.any? && !%w(compose run ssh dns provision version --help).includes?(argv[0])
  argv = %w(run) + argv
end

exit Dip::Cli.run(argv).as(Int32)
