require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Clean the build files for the solaris-file source"
task :clean do
   FileUtils.rm_rf('solaris') if File.exists?('solaris')

   Dir.chdir('ext') do
      FileUtils.rm_rf('sfile.c') if File.exists?('sfile.c')
      FileUtils.rm_rf('sfile.h') if File.exists?('sfile.h')
      sh 'make distclean' if File.exists?('file.so')
      FileUtils.rm_rf('solaris/file.so') if File.exists?('solaris/file.so')
   end
end

desc "Build the solaris-file package (but don't install it)"
task :build => [:clean] do
   Dir.chdir('ext') do
      ruby 'extconf.rb'
      sh 'make'
      Dir.mkdir('solaris') unless File.exists?('solaris')
      FileUtils.cp('file.so', 'solaris')
   end
end

desc "Install the solaris-file package (non-gem)"
task :install => [:build] do
   Dir.chdir('ext') do
      sh 'make install'
   end
end

desc "Install the solaris-file package as a gem"
task :install_gem do
   ruby 'solaris-file.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
end

desc "Uninstall the solaris-file package. Use 'gem uninstall' for gem installs"
task :uninstall => [:clean] do
   file = File.join(CONFIG['sitearchdir'], 'solaris', 'file.so')
   FileUtils.rm_rf(file, :verbose => true) if File.exists?(file)
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
