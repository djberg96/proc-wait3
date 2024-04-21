require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'proc-wait3'
  spec.version    = '1.9.1'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Apache-2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/proc-wait3'
  spec.summary    = 'Adds wait3, wait4 and other methods to the Process module'
  spec.test_file  = 'spec/proc_wait3_spec.rb'
  spec.extensions = ['ext/extconf.rb']
  spec.files      = Dir['**/*'].reject { |f| f.include?('git') }
  spec.cert_chain = Dir['certs/*']

  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec', '~> 3.9')
  spec.add_development_dependency('rubocop')
  spec.add_development_dependency('rubocop-rspec')

  spec.metadata = {
    'homepage_uri'          => 'https://github.com/djberg96/proc-wait3',
    'bug_tracker_uri'       => 'https://github.com/djberg96/proc-wait3/issues',
    'changelog_uri'         => 'https://github.com/djberg96/proc-wait3/blob/main/CHANGES.md',
    'documentation_uri'     => 'https://github.com/djberg96/proc-wait3/wiki',
    'source_code_uri'       => 'https://github.com/djberg96/proc-wait3',
    'wiki_uri'              => 'https://github.com/djberg96/proc-wait3/wiki',
    'rubygems_mfa_required' => 'true'
  }

  spec.description = <<-EOF
    The proc-wait3 library adds the wait3, wait4, waitid, pause, sigsend,
    and getrusage methods to the Process module.
  EOF
end
