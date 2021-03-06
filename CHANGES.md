## 0.4.2 - 18-Dec-2015
* This gem is now signed.
* The gem tasks in the Rakefile now assume Rubygems 2.x.
* Added a solaris-file.rb file convenience.

## 0.4.1 - 2-Nov-2014
* Minor updates to the Rakefile and gemspec.

## 0.4.0 - 13-Jan-2013
* Converted to FFI.
* Removed the File.realpath method since it is now already defined in
  Ruby 1.9 and later.
* Updated the tests and Rakefile.

## 0.3.7 - 29-Jul-2011
* Removed an obsolete gemspec attribute.
* Fixed redefinition warnings for the ftype and realpath singleton methods.

## 0.3.6 - 12-Dec-2010
* Fixed a warning regarding an unused variable.
* Fixed a potential bug with an internal helper function's switch statement.
* Refactored the Rakefile and the gemspec. 
* Updated the installation instructions in the README.

## 0.3.5 - 28-Aug-2009
* Changed the license to Artistic 2.0.
* Added test-unit 2.x and sys-filesystem as development dependencies.
* Some updates to the gemspec, including license and description. 
* Refactored the test suite to use the features of 2.x, added several
  more tests, and now skips some tests unless it's a UFS filesystem.
* Renamed the test and example files.

## 0.3.4 - 4-Feb-2008
* Updated the extconf.rb file so that it sets the target prefix properly.
* No actual source code changes.

## 0.3.3 - 20-Aug-2007
* Added the File.door? method, and the underlying File::Stat#door? method,
  that returns whether or not the file is a door file.
* Modified the File.ftype method, and the underlying File::Stat#ftype method,
  so that the word 'door' is returned if the file is a door file.
* Added tests for the new and updated methods.
* These modifications were inspired by Hiro Asari (ruby-core: 11890).

## 0.3.2 - 24-Jul-2007
* Added a Rakefile with tasks for testing and installation.
* Fixed an internal function name that conflicted with one in the acl.h file.
  (I'm guessing this was a recent development for me not to notice until now).
* Internal layout changes that don't affect you. 

## 0.3.1 - 11-Jul-2006
* Fixed a potential 64 bit bug in a struct declaration.
* Minor RDoc updates, changes and internal cosmetic changes.

## 0.3.0 - 13-Jun-2005
* Added the File.resolvepath and File.realpath methods.
* Code cleanup.  Attempting to pass a path greater than PATH_MAX
  now raises an ArgumentError.
* More tests added.

## 0.2.0 - 1-Apr-2005
* The Solaris::FileError class has been changed to File::SolarisError.
* Added internal taint checking for methods that accept String arguments.
* Improved error handling and general cleanup.
* Added README and CHANGES files.  The former replaces the doc/file.txt file.
* Added a gemspec.

## 0.1.0 - 27-Jan-2005
* Initial release.
