require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'proc-wait3'
  spec.version    = '1.5.6'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://www.rubyforge.org/projects/shards'
  spec.platform   = Gem::Platform::RUBY
  spec.summary    = 'Adds wait3, wait4 and other methods to the Process module'
  spec.test_file  = 'test/test_proc_wait3.rb'
  spec.has_rdoc   = true
  spec.extensions = ['ext/extconf.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.required_ruby_version = '>= 1.8.6'

  spec.rubyforge_project = 'shards'
  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'ext/proc/wait3.c']

  spec.add_development_dependency('test-unit', '>= 2.0.3')

  spec.description = <<-EOF
    The proc-wait3 library adds the wait3, wait4, waitid, pause, sigsend,
    and getrusage methods to the Process module. It also adds the getrlimit
    and setrlimit methods for Ruby 1.8.4 or earlier.
  EOF
end
