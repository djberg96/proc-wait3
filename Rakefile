require 'rake'
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'fileutils'
require 'rbconfig'
include RbConfig

CLEAN.include(
  '**/*.gem',                # Gem files
  '**/*.rbc',                # Rubinius
  '**/*.o',                  # C object file
  '**/*.log',                # Ruby extension build log
  '**/*.lock',               # Gemfile.lock
  '**/Makefile',             # C Makefile
  '**/conftest.dSYM',        # OS X build directory
  "**/*.#{CONFIG['DLEXT']}", # C shared object
  '**/*.lock'                # Bundler
)

desc "Build the source (but don't install it)"
task :build => [:clean] do |t|
  Dir.chdir('ext') do
    ruby 'extconf.rb'
    sh 'make'
    FileUtils.mv 'wait3.' + RbConfig::CONFIG['DLEXT'], 'proc'
  end
end

namespace :gem do
  desc 'Create the proc-wait3 gem'
  task :create => [:clean] do
    require 'rubygems/package'
    spec = Gem::Specification.load('proc-wait3.gemspec')
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec)
  end

  desc 'Install the proc-wait3 gem'
  task :install => [:create] do |t|
    file = Dir['*.gem'].first
    sh "gem install -l #{file}"
  end
end

namespace :example do
  desc 'Run the Process.getrusage example program'
  task :getrusage => [:build] do
    ruby '-Iext examples/example_getrusage.rb'
  end

  desc 'Run the Process.pause example program'
  task :pause => [:build] do
    ruby '-Iext examples/example_pause.rb'
  end

  desc 'Run the Process.wait3 example program'
  task :wait3 => [:build] do
    ruby '-Iext examples/example_wait3.rb'
  end

  desc 'Run the Process.wait4 example program'
  task :wait4 => [:build] do
    ruby '-Iext examples/example_wait4.rb'
  end

  desc 'Run the Process.waitid example program'
  task :waitid => [:build] do
    ruby '-Iext examples/example_waitid.rb'
  end
end

desc 'Run the test suite'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-Iext -f documentation'
end

# Clean up afterwards
Rake::Task[:spec].enhance do
  Rake::Task[:clean].invoke
end

task :default => [:build, :spec]

RuboCop::RakeTask.new
