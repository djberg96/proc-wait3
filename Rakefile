require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'fileutils'
require 'rbconfig'
include RbConfig

CLEAN.include(
  '**/*.gem',               # Gem files
  '**/*.rbc',               # Rubinius
  '**/*.o',                 # C object file
  '**/*.log',               # Ruby extension build log
  '**/Makefile',            # C Makefile
  '**/conftest.dSYM',       # OS X build directory
  "**/*.#{CONFIG['DLEXT']}" # C shared object
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
  desc "Create the proc-wait3 gem"
  task :create => [:clean] do
    require 'rubygems/package'
    spec = eval(IO.read('proc-wait3.gemspec'))
    spec.signing_key = File.join(Dir.home, '.ssh', 'gem-private_key.pem')
    Gem::Package.build(spec, true)
  end

  desc "Install the proc-wait3 gem"
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

Rake::TestTask.new do |t|
  task :test => [:build]
  t.libs << 'ext'
  t.warning = true
  t.verbose = true
end

task :default => :test
