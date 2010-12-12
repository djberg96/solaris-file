require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include(
  '**/*.gem',               # Gem files
  '**/*.rbc',               # Rubinius
  '**/*.o',                 # C object file
  '**/*.log',               # Ruby extension build log
  '**/Makefile',            # C Makefile
  '**/conftest.dSYM',       # OS X build directory
  "**/*.#{CONFIG['DLEXT']}" # C shared object
)

desc "Build the solaris-file package (but don't install it)"
task :build => [:clean] do
  Dir.chdir('ext') do
    ruby 'extconf.rb'
    sh 'make'
    Dir.mkdir('solaris') unless File.exists?('solaris')
    FileUtils.cp('file.so', 'solaris')
  end
end

namespace :gem do
  desc "Create the solaris-file gem"
  task :create => [:clean] do
    spec = eval(IO.read('solaris-file.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc "Install the solaris-file gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the example program"
task :example => [:build] do
  ruby "-Iext examples/example_solaris_file.rb"
end

Rake::TestTask.new do |t|
  task :test => :build
  t.libs << 'ext'
  t.warning = true
  t.verbose = true
end

task :default => :test
