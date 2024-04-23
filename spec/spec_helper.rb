# frozen_string_literal: true

require 'rspec'
require 'proc-wait3'

RSpec.configure do |config|
  config.filter_run_excluding(:darwin) if Gem::Platform.local.os !~ /darwin|macos/i
  config.filter_run_excluding(:solaris) if Gem::Platform.local.os !~ /sunos|solaris/i
  config.filter_run_excluding(:bsd) if Gem::Platform.local.os !~ /bsd|dragonfly/i
  config.filter_run_excluding(:linux) if Gem::Platform.local.os !~ /linux/i

  config.filter_run_excluding(:skip_hpux) if Gem::Platform.local.os =~ /hpux/i
  config.filter_run_excluding(:skip_darwin) if Gem::Platform.local.os =~ /darwin|macos/i
  config.filter_run_excluding(:skip_bsd) if Gem::Platform.local.os =~ /bsd|dragonfly/i
end
