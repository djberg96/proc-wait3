require 'rake'
require 'rake/testtask'
require 'fileutils'

desc "Clean the generated build files"
task :clean do |t|
  Dir.chdir('ext') do
    sh 'make distclean' if File.exists?('wait3.o')
    rm 'proc/wait3.' + Config::CONFIG['DLEXT'] rescue nil
  end
end

desc "Build the source (but don't install it)"
task :build => [:patch, :clean] do |t|
  Dir.chdir('ext') do
    ruby 'extconf.rb'
    sh 'make'
    FileUtils.mv 'wait3.' + Config::CONFIG['DLEXT'], 'proc'
  end
end

desc "Install the proc-wait3 library"
task :install => [:build] do |t|
  sh 'make install'
end

desc 'Run the Process.getrusage example program'
task :example_getrusage => [:build] do
  ruby '-Iext examples/example_getrusage.rb'
end

desc 'Run the Process.pause example program'
task :example_pause => [:build] do
  ruby '-Iext examples/example_pause.rb'
end

desc 'Run the Process.wait3 example program'
task :example_wait3 => [:build] do
  ruby '-Iext examples/example_wait3.rb'
end

desc 'Run the Process.wait4 example program'
task :example_wait4 => [:build] do
  ruby '-Iext examples/example_wait4.rb'
end

desc 'Run the Process.waitid example program'
task :example_waitid => [:build] do
  ruby '-Iext examples/example_waitid.rb'
end

Rake::TestTask.new do |t|
  task :test => [:build]
  t.libs << 'ext'
  t.warning = true
  t.verbose = true
end

desc "Patch your mkmf.rb file so that it supports have_const. Must be root."
task :patch do |t|
   require 'mkmf'
   unless defined? have_const
      file = File.join(Config::CONFIG['rubylibdir'], 'mkmf.rb')
      date = Time.now
      
      FileUtils.cp(file, 'mkmf.orig') # Backup original

      File.open(file, 'a'){ |fh|
         fh.puts %Q{
# Returns whether or not the constant +const+ can be found in the common
# header files, or within a +header+ that you provide. If found, a macro is
# passed as a preprocessor constant to the compiler using the constant name,
# in uppercase, prepended with 'HAVE_'. This method is also used to test
# for the presence of enum values.
# 
# For example, if have_const('FOO') returned true, then the HAVE_CONST_FOO
# preprocessor macro would be passed to the compiler.
#
# This method was added automatically by the proc-wait3 library on
# #{date}.
#
def have_const(const, header = nil, opt = "", &b)
   checking_for const do
      header = cpp_include(header)
      if try_compile(<<"SRC", opt, &b)
#\{COMMON_HEADERS\}
#\{header\}
/* top */
static int t = #\{const\};
SRC
         $defs.push(
            format(
               "-DHAVE_CONST_%s",
               const.strip.upcase.tr_s("^A-Z0-9_", "_")
            )
         )
         true
      else
         false
      end
   end
end}
      }
   end
end
