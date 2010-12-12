require 'rubygems'

Gem::Specification.new do |gem|
  gem.name       = 'solaris-file'
  gem.version    = '0.3.5'
  gem.author     = 'Daniel J. Berger'
  gem.license    = 'Artistic 2.0'
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'http://www.rubyforge.org/projects/solarisutils'
  gem.platform   = Gem::Platform::RUBY
  gem.summary    = 'ACL and other methods for the File class on Solaris'
  gem.has_rdoc   = true
  gem.test_file  = 'test/test_solaris_file.rb'
  gem.extensions = ['ext/extconf.rb']
  gem.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  gem.rubyforge_project = 'solarisutils'

  gem.extra_rdoc_files = [
    'README',
    'CHANGES',
    'MANIFEST',
    'ext/solaris/sfile.c'
  ]

  gem.add_development_dependency('test-unit', '>= 2.1.1')
  gem.add_development_dependency('sys-filesystem', '>= 0.3.1')

  gem.description = <<-EOF
    The solaris-file library provides Solaris-specific access control
    methods to the File class. It also provides methods for identifying
    trivial and door files, interfaces for the realpath() and resolvepath()
    functions, and an overloaded ftype method.
  EOF
end
