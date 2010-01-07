require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name       = 'proc-wait3'
   gem.version    = '1.5.5'
   gem.author     = 'Daniel J. Berger'
   gem.license    = 'Artistic 2.0'
   gem.email      = 'djberg96@gmail.com'
   gem.homepage   = 'http://www.rubyforge.org/projects/shards'
   gem.platform   = Gem::Platform::RUBY
   gem.summary    = 'Adds wait3 and other methods to the Process module'
   gem.test_file  = 'test/test_proc_wait3.rb'
   gem.has_rdoc   = true
   gem.extensions = ['ext/extconf.rb']
   gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'shards'
   gem.required_ruby_version = '>= 1.8.2'
   gem.extra_rdoc_files = ['CHANGES', 'README', 'MANIFEST', 'ext/proc/wait3.c']

   gem.add_development_dependency('test-unit', '>= 2.0.3')

   gem.description = <<-EOF
      The proc-wait3 library adds the wait3, wait4, waitid, pause, sigsend,
      and getrusage methods to the Process module. It also adds the getrlimit
      and setrlimit methods for Ruby 1.8.4 or earlier.
   EOF
end

Gem::Builder.new(spec).build
