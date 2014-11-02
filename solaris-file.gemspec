require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'solaris-file'
  spec.version    = '0.4.1'
  spec.author     = 'Daniel J. Berger'
  spec.license    = 'Artistic 2.0'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://www.github.com/djberg96/solaris-file'
  spec.summary    = 'ACL and other methods for the File class on Solaris'
  spec.test_file  = 'test/test_solaris_file.rb'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files = [
    'README',
    'CHANGES',
    'MANIFEST',
  ]

  spec.add_development_dependency('test-unit', '>= 2.5.0')
  spec.add_development_dependency('sys-filesystem', '>= 0.3.1')

  spec.description = <<-EOF
    The solaris-file library provides Solaris-specific access control
    methods to the File class. It also provides methods for identifying
    trivial and door files, an interfaces for the resolvepath()
    function, and an overloaded ftype method.
  EOF
end
