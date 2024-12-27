#!/usr/bin/env ruby

require 'dip/version'

puts Dip::VERSION

system("gem install dip-#{Dip::VERSION}.gem")
