## Notice
Since Solaris is all but dead at this point, this library is no longer being
actively maintained, except perhaps for the occasional doc update. If you wish
to take over maintenance, please send me an email offline and we can discuss
a transfer of the repository.

## Description
Adds ACL support and door methods for the File class on Solaris.

## Installation
`gem install solaris-file`

## Synopsis
```ruby
require 'solaris/file'
 
file = 'some_file.txt'
acl_text = "user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:r--"
 
File.trivial?(file) # => true (probably)
File.acl_write_text(acl_text)
 
# No longer a trivial file
File.trivial?(file) # => false
File.acl_read(file).each{ |acl| p acl }

# Door file?
File.door?("/var/run/syslog_door") # => true
File.ftype("/var/run/syslog_door") # => 'door'
```

## Known Issues
Although this libary uses FFI, the instance methods will probably not work
when using JRuby because of the underlying use of file descriptors. However,
the singleton methods should work.
   
## Future Plans
None. Please see the Notice at the top regarding the status of this library.
   
## Copyright
(C) 2005-2021 Daniel J. Berger
All Rights Reserved
    
## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.
	
## License
Artistic-2.0
    
## Author
Daniel J. Berger
