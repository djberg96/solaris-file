require 'mkmf'
require 'fileutils'

dir_config('file')

$INCFLAGS += " -Isolaris"

have_library('sec')
create_makefile('solaris/file', 'solaris')
