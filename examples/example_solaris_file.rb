#######################################################################
# example_solaris_file.rb
#
# Example script for general futzing. You can run this script via
# the 'rake example' task.
#
# Modify as you see fit.
#######################################################################
require "solaris/file"
require "pp"

Dir.chdir File.dirname(File.expand_path(__FILE__))

puts
puts "Version: " + File::SOLARIS_VERSION
puts "-" * 20

file1 = "foo.txt"
file2 = "bar.txt"

File.open(file1,"w+"){ |fh| fh.puts "foo" }
File.open(file2,"w+"){ |fh| fh.puts "bar" }

acl_text = "user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:r--"
acl_text2 = "user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:rw-"

pp File.acl_count(file1)     # Should be 0
pp File.acl_read(file1)      # Should return nil
pp File.acl_read_text(file1) # Should return nil
pp File.trivial?(file1)      # Should return true

File.acl_write_text(file1,acl_text)

pp File.acl_count(file1)     # Should now be 6
pp File.acl_read(file1)      # Should return 6 ACL Struct's
pp File.acl_read_text(file1) # Should return an string like 'acl_text' above
pp File.trivial?(file1)      # Should return false

pp File.acl_count(file2)
pp File.acl_read(file2)
pp File.acl_read_text(file2)
pp File.trivial?(file2)

# Use instance methods instead this time
File.open(file2){ |fh|
   fh.acl_write_text(acl_text2)
   pp fh.acl_count
   pp fh.acl_read
   pp fh.acl_read_text
   pp fh.trivial?
}

File.delete(file1) if File.exists?(file1)
File.delete(file2) if File.exists?(file2)
