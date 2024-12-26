#!/bin/bash

gem build dip.gemspec

gem install ./dip-8.2.6.gem --user-install
