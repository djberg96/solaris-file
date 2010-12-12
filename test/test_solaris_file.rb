###############################################################################
# test_solaris_file.rb
#
# Test suite for the solaris-file package. You should run this test case
# via the 'rake test' task. Note that many tests will be skipped unless you're
# on a UFS filesystem.
###############################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'solaris/file'
require 'sys/filesystem'

class TC_Solaris_File < Test::Unit::TestCase
   def self.startup
      Dir.chdir(File.dirname(File.expand_path(__FILE__)))

      @@ufs   = Sys::Filesystem.stat(Dir.pwd).base_type == 'ufs'
      @@file1 = File.join(Dir.pwd, 'foo.txt') # trivial
      @@file2 = File.join(Dir.pwd, 'bar.txt') # non-trivial

      @@acl_text = 'user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:r--'

      File.open(@@file1, 'w'){ |fh| fh.puts 'foo' }
      File.open(@@file2, 'w'){ |fh| fh.puts 'bar' }
   end

   def setup
      @dir  = Dir.pwd
      @door = '/var/run/syslog_door'
      @stat = File::Stat.new(@door)

      # Make @@file2 a non-trivial file. UFS only.
      if @@ufs
         system("chmod A=#{@@acl_text} #{@@file2}")
      end

      @handle1 = File.open(@@file1)
      @handle2 = File.open(@@file2)
   end

   def test_version
      assert_equal('0.3.6', File::SOLARIS_VERSION)
   end

   # SINGLETON METHODS

   def test_singleton_acl_read_basic
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_respond_to(File, :acl_read)
      assert_nothing_raised{ File.acl_read(@@file1) }
   end

   def test_singleton_acl_read
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_nil(File.acl_read(@@file1))
      assert_kind_of(Array, File.acl_read(@@file2))
   end

   def test_singleton_acl_read_expected_errors
      assert_raise(Errno::ENOENT){ File.acl_read('bogus') }
      assert_raise(ArgumentError){ File.acl_read('bogus' * 500) }
      assert_raise(ArgumentError){ File.acl_read }
      assert_raise(TypeError){ File.acl_read(1) }
   end

   def test_singleton_acl_read_text_basic
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_respond_to(File, :acl_read_text)
      assert_nothing_raised{ File.acl_read_text(@@file1) }
   end

   def test_singleton_acl_read_text
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_nil(File.acl_read_text(@@file1))
      assert_kind_of(String,File.acl_read_text(@@file2))
   end

   def test_singleton_acl_read_text_expected_errors
      assert_raise(Errno::ENOENT){ File.acl_read_text('bogus') }
      assert_raise(ArgumentError){ File.acl_read_text }
      assert_raise(TypeError){ File.acl_read_text(1) }
   end

   def test_singleton_acl_write_text
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      acl_text = 'user::rw-,group::r--,mask:r--,other:---'
      assert_respond_to(File, :acl_write_text)
      assert_nothing_raised{ File.acl_write_text(@@file1, acl_text) }
   end

   def test_singleton_acl_write_text_expected_errors
      assert_raise(File::SolarisError){ File.acl_write_text(@@file1, 'bogus') }
   end

   def test_singleton_acl_trivial_basic
      assert_respond_to(File, :trivial?)
      assert_nothing_raised{ File.trivial?(@@file1) }
      assert_boolean(File.trivial?(@@file1))
   end

   def test_singleton_acl_trivial
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_true(File.trivial?(@@file1))
      assert_false(File.trivial?(@@file2))
   end

   def test_singleton_acl_trivial_expected_errors
      assert_raise(Errno::ENOENT){ File.trivial?('bogus') }
      assert_raise(ArgumentError){ File.trivial?('bogus' * 500) }
      assert_raise(ArgumentError){ File.trivial? }
      assert_raise(TypeError){ File.trivial?(1) }
   end

   def test_singleton_acl_count
      assert_respond_to(File, :acl_count)
      assert_nothing_raised{ File.acl_count(@@file1) }
      assert_kind_of(Fixnum, File.acl_count(@@file1))
   end

   def test_singleton_acl_count_expected_errors
      assert_raise(Errno::ENOENT){ File.acl_count('bogus') }
      assert_raise(ArgumentError){ File.acl_count('bogus' * 500) }
      assert_raise(ArgumentError){ File.acl_count }
      assert_raise(TypeError){ File.acl_count(1) }
   end

   def test_singleton_realpath_basic
      assert_respond_to(File, :realpath)
      assert_nothing_raised{ File.realpath(@dir) }
      assert_kind_of(String, File.realpath(@dir))
   end

   def test_singleton_realpath
      dir1 = File.join(File.dirname(Dir.pwd), 'examples')
      dir2 = File.join(Dir.pwd, '/.././examples')

      assert_equal(@dir, File.realpath(@dir))
      assert_equal(dir1, File.realpath(dir2))
   end

   def test_singleton_realpath_expected_errors
      assert_raise(Errno::ENOENT){ File.realpath('bogus') }
      assert_raise(ArgumentError){ File.realpath }
      assert_raise(TypeError){ File.realpath(1) }
   end

   def test_singleton_resolvepath_basic
      assert_respond_to(File, :resolvepath)
      assert_nothing_raised{ File.resolvepath(@dir) }
      assert_kind_of(String, File.resolvepath(@dir))
   end

   def test_singleton_resolvepath
      assert_equal(@dir, File.resolvepath(@dir))
      assert_equal("../examples", File.resolvepath("../examples"))
   end

   def test_singleton_resolvepath_expected_errors
      assert_raise(Errno::ENOENT){ File.resolvepath('bogus') }
      assert_raise(ArgumentError){ File.resolvepath }
      assert_raise(TypeError){ File.resolvepath(1) }
   end

   def test_singleton_is_door_basic
      assert_respond_to(File, :door?)
      assert_nothing_raised{ File.door?(@door) }
      assert_boolean(File.door?(@door))
   end
   
   def test_singleton_is_door
      assert_true(File.door?(@door))
      assert_false(File.door?(Dir.pwd))
   end

   def test_singleton_is_door_expected_errors
      assert_raise(Errno::ENOENT){ File.door?('bogus') }
      assert_raise(ArgumentError){ File.door? }
      assert_raise(TypeError){ File.door?(1) }
   end

   def test_singleton_ftype_basic
      assert_respond_to(File, :ftype)
   end

   def test_singleton_ftype
      assert_equal('door', File.ftype(@door))
      assert_equal('directory', File.ftype(Dir.pwd))
   end

   def test_singleton_ftype_expected_errors
      assert_raise(Errno::ENOENT){ File.ftype('bogus') }
      assert_raise(ArgumentError){ File.ftype }
      assert_raise(TypeError){ File.ftype(1) }
   end

   # INSTANCE METHODS

   def test_instance_acl_basic
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_respond_to(@handle1, :acl_read)
      assert_nothing_raised{ @handle1.acl_read }
   end

   def test_instance_acl
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_nil(@handle1.acl_read)
      assert_kind_of(Array, @handle2.acl_read)
      assert_kind_of(Struct::ACLStruct, @handle2.acl_read.first)
   end

   def test_instance_acl_read_text_basic
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_respond_to(@handle1, :acl_read_text)
      assert_nothing_raised{ @handle1.acl_read_text }
   end

   def test_instance_acl_read_text
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_nil(@handle1.acl_read_text)
      assert_kind_of(String, @handle2.acl_read_text)
   end

   def test_instance_acl_write_text
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      acl_text = 'user::rw-,group::r--,mask:r--,other:---'
      assert_respond_to(@handle2, :acl_write_text)
      assert_nothing_raised{ @handle2.acl_write_text(acl_text) }
   end

   def test_instance_acl_write_text_expected_errors
      assert_raise(File::SolarisError){ @handle2.acl_write_text('bogus') }
      assert_raise(ArgumentError){ @handle2.acl_write_text }
      assert_raise(TypeError){ @handle2.acl_write_text(1) }
   end

   def test_instance_acl_trivial_basic
      assert_respond_to(@handle1, :trivial?)
      assert_nothing_raised{ @handle1.trivial? }
      assert_boolean(@handle1.trivial?)
   end

   def test_instance_acl_trivial
      assert_true(@handle1.trivial?)
      assert_false(@handle2.trivial?)
   end

   def test_instance_acl_count_basic
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_respond_to(@handle1, :acl_count)
      assert_nothing_raised{ @handle1.acl_count }
      assert_kind_of(Fixnum, @handle1.acl_count)
   end

   def test_instance_acl_count
      omit_unless(@@ufs, 'skipped on non-ufs filesystem')
      assert_equal(0, @handle1.acl_count)
      assert_equal(6, @handle2.acl_count)
   end

   def test_stat_door
      assert_respond_to(@stat, :door?)
      assert_true(@stat.door?)
   end

   def test_stat_ftype
      assert_respond_to(@stat, :ftype)
      assert_equal('door', @stat.ftype)
   end

   def teardown
      @handle1.close unless @handle1.closed?
      @handle2.close unless @handle2.closed?

      @dir     = nil
      @handle1 = nil
      @handle2 = nil
   end

   def self.shutdown
      File.delete(@@file1) if File.exists?(@@file1)
      File.delete(@@file2) if File.exists?(@@file2)

      @@ufs = nil
      @@file1 = nil
      @@file2 = nil
      @@acl_text = nil
   end
end
