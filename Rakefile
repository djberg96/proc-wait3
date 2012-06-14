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

namespace :gem do
  desc "Create the proc-wait3 gem"
  task :create => [:clean] do
    spec = eval(IO.read('proc-wait3.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the proc-wait3 gem"
  task :install => [:create] do |t|
    file = Dir['*.gem'].first
    sh "gem install #{file}"
  end
end

namespace :example do
  desc 'Run the Process.getrusage example program'
  task :getrusage do
    ruby '-Iext examples/example_getrusage.rb'
  end

  desc 'Run the Process.pause example program'
  task :pause do
    ruby '-Iext examples/example_pause.rb'
  end

  desc 'Run the Process.wait3 example program'
  task :wait3 do
    ruby '-Iext examples/example_wait3.rb'
  end

  desc 'Run the Process.wait4 example program'
  task :wait4 do
    ruby '-Iext examples/example_wait4.rb'
  end

  desc 'Run the Process.waitid example program'
  task :waitid do
    ruby '-Iext examples/example_waitid.rb'
  end
end

Rake::TestTask.new do |t|
  task :test => [:clean]
  t.warning = true
  t.verbose = true
end

task :default => :test
