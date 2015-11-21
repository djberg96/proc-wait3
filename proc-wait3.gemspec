require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'proc-wait3'
  spec.version    = '1.7.3'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/proc-wait3'
  spec.summary    = 'Adds wait3, wait4 and other methods to the Process module'
  spec.test_file  = 'test/test_proc_wait3.rb'
  spec.extensions = ['ext/extconf.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'ext/proc/wait3.c']

  spec.add_development_dependency('test-unit')
  spec.add_development_dependency('rake')

  spec.description = <<-EOF
    The proc-wait3 library adds the wait3, wait4, waitid, pause, sigsend,
    and getrusage methods to the Process module.
  EOF
end
