###############################################################################
# test_solaris_file.rb
#
# Test suite for the solaris-file package. You should run this test case
# via the 'rake test' task. Note that many tests will be skipped unless you're
# on a UFS filesystem.
###############################################################################
require 'test-unit'
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
    assert_equal('0.4.0', File::SOLARIS_VERSION)
  end

  # SINGLETON METHODS

  test "acl_read singleton method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_respond_to(File, :acl_read)
    assert_nothing_raised{ File.acl_read(@@file1) }
  end

  test "acl_read singleton method works as expected" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_nil(File.acl_read(@@file1))
    assert_kind_of(Array, File.acl_read(@@file2))
    assert_kind_of(Struct::ACLStruct, File.acl_read(@@file2).first)
  end

  test "acl_read singleton method returns expected struct values" do
    struct = File.acl_read(@@file2).first
    assert_equal('user', struct.acl_type)
    assert_equal(100, struct.acl_id)
    assert_equal(6, struct.acl_perm)
  end

  test "acl_read singleton method requires a single argument" do
    assert_raise(ArgumentError){ File.acl_read }
    assert_raise(ArgumentError){ File.acl_read(@@file1, @@file2) }
  end

  test "acl_read singleton method raises an error if the file is not found" do
    assert_raise(Errno::ENOENT){ File.acl_read('bogus') }
  end

  test "acl_read singleton method requires a string argument" do
    assert_raise(TypeError){ File.acl_read(1) }
  end

  test "acl_read_text singleton method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_respond_to(File, :acl_read_text)
    assert_nothing_raised{ File.acl_read_text(@@file1) }
  end

  test "acl_read_text singleton method returns expected type of value" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_nil(File.acl_read_text(@@file1))
    assert_kind_of(String, File.acl_read_text(@@file2))
    assert_equal(@@acl_text, File.acl_read_text(@@file2))
  end

  test "acl_read_text singleton method requires a single argument only" do
    assert_raise(ArgumentError){ File.acl_read_text }
    assert_raise(ArgumentError){ File.acl_read_text(@@file1, @@file2) }
  end

  test "acl_read_text singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.acl_read_text('bogus') }
  end

  test "acl_read_text singleton method requires a string argument" do
    assert_raise(TypeError){ File.acl_read_text(1) }
  end

  test "acl_write_text singleton method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    acl_text = 'user::rw-,group::rw-,mask:r--,other:---'
    assert_respond_to(File, :acl_write_text)
    assert_nothing_raised{ File.acl_write_text(@@file1, acl_text) }
    assert_kind_of(String, File.acl_write_text(@@file1, acl_text))
  end

  test "acl_write_text singleton method works as expected" do
    acl_text = 'user::rw-,group::rw-,mask:r--,other:---'
    assert_equal(acl_text, File.acl_write_text(@@file1, acl_text))
    #assert_equal(acl_text, File.acl_read_text(@@file1))
  end

  test "acl_write_text singleton method if text is invalid" do
    assert_raise(ArgumentError){ File.acl_write_text(@@file1, 'bogus') }
    assert_raise_message('invalid ACL text'){ File.acl_write_text(@@file1, 'bogus') }
  end

  test "trivial? singleton method basic functionality" do
    assert_respond_to(File, :trivial?)
    assert_nothing_raised{ File.trivial?(@@file1) }
    assert_boolean(File.trivial?(@@file1))
  end

  test "trivial? singleton method returns the expected value" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_true(File.trivial?(@@file1))
    assert_false(File.trivial?(@@file2))
  end

  test "trivial? singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.trivial?('bogus') }
    assert_raise(Errno::ENAMETOOLONG){ File.trivial?('bogus' * 500) }
  end

  test "trivial? singleton method requires a single string argument" do
    assert_raise(ArgumentError){ File.trivial? }
    assert_raise(TypeError){ File.trivial?(1) }
  end

  test "acl_count singleton method basic functionality" do
    assert_respond_to(File, :acl_count)
    assert_nothing_raised{ File.acl_count(@@file1) }
    assert_kind_of(Fixnum, File.acl_count(@@file1))
  end

  test "acl_count singleton method returns the expected value" do
    assert_equal(0, File.acl_count(@@file1))
    assert_equal(6, File.acl_count(@@file2))
  end

  test "acl_count singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.acl_count('bogus') }
    assert_raise(Errno::ENAMETOOLONG){ File.acl_count('bogus' * 500) }
  end

  test "acl_count singleton method requires a single string argument" do
    assert_raise(ArgumentError){ File.acl_count }
    assert_raise(TypeError){ File.acl_count(1) }
  end

=begin
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
=end

  test "resolvepath singleton method basic functionality" do
    assert_respond_to(File, :resolvepath)
    assert_nothing_raised{ File.resolvepath(@dir) }
    assert_kind_of(String, File.resolvepath(@dir))
  end

  test "resolvepath singleton method returns the expected value" do
    assert_equal(@dir, File.resolvepath(@dir))
    assert_equal("../examples", File.resolvepath("../examples"))
  end

  test "resolvepath singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.resolvepath('bogus') }
  end

  test "resolvepath requires a single string argument" do
    assert_raise(ArgumentError){ File.resolvepath }
    assert_raise(TypeError){ File.resolvepath(1) }
  end

  test "door? singleton method basic functionality" do
    assert_respond_to(File, :door?)
    assert_nothing_raised{ File.door?(@door) }
    assert_boolean(File.door?(@door))
  end

  test "door? singleton method returns the expected result" do
    assert_true(File.door?(@door))
    assert_false(File.door?(Dir.pwd))
  end

  test "door? singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.door?('bogus') }
  end

  test "door? singleton method requires a single string argument" do
    assert_raise(ArgumentError){ File.door? }
    assert_raise(TypeError){ File.door?(1) }
  end

  test "ftype singleton method is still defined" do
    assert_respond_to(File, :ftype)
  end

  test "overridden ftype singleton method returns expected value" do
    assert_equal('door', File.ftype(@door))
    assert_equal('directory', File.ftype(Dir.pwd))
  end

  test "ftype singleton method raises an error if the argument is invalid" do
    assert_raise(Errno::ENOENT){ File.ftype('bogus') }
  end

  test "ftype singleton method requires a single string argument" do
    assert_raise(ArgumentError){ File.ftype }
    assert_raise(TypeError){ File.ftype(1) }
  end

  # INSTANCE METHODS

  test "acl_read instance method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_respond_to(@handle1, :acl_read)
    assert_nothing_raised{ @handle1.acl_read }
  end

  test "acl_read instance method works as expected" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_nil(@handle1.acl_read)
    assert_kind_of(Array, @handle2.acl_read)
    assert_kind_of(Struct::ACLStruct, @handle2.acl_read.first)
  end

  test "acl_read instance method does not accept any arguments" do
    assert_raise(ArgumentError){ @handle1.acl_read('test.txt') }
  end

  test "acl_read_text instance method dbasic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_respond_to(@handle1, :acl_read_text)
    assert_nothing_raised{ @handle1.acl_read_text }
  end

  test "acl_read_text instance method returns expected value" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_nil(@handle1.acl_read_text)
    assert_kind_of(String, @handle2.acl_read_text)
  end

  test "acl_write_text instance method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    acl_text = 'user::rw-,group::r--,mask:r--,other:---'
    assert_respond_to(@handle2, :acl_write_text)
    assert_nothing_raised{ @handle2.acl_write_text(acl_text) }
  end

  test "acl_write_text instance method requires a single string argument" do
    assert_raise(ArgumentError){ @handle2.acl_write_text }
    assert_raise(TypeError){ @handle2.acl_write_text(1) }
  end

  test "acl_write_text instance method requires a valid acl string" do
    assert_raise(ArgumentError){ @handle2.acl_write_text('bogus') }
  end

  test "trivial? instance method basic functionality" do
    assert_respond_to(@handle1, :trivial?)
    assert_nothing_raised{ @handle1.trivial? }
    assert_boolean(@handle1.trivial?)
  end

  test "trivial? instance method returns the expected value" do
    assert_true(@handle1.trivial?)
    assert_false(@handle2.trivial?)
  end

  test "acl_count instance method basic functionality" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_respond_to(@handle1, :acl_count)
    assert_nothing_raised{ @handle1.acl_count }
    assert_kind_of(Fixnum, @handle1.acl_count)
  end

  test "acl_count instance method returns the expected value" do
    omit_unless(@@ufs, 'skipped on non-ufs filesystem')
    assert_equal(0, @handle1.acl_count)
    assert_equal(6, @handle2.acl_count)
  end

  test "door? instance method basic functionality" do
    assert_respond_to(@stat, :door?)
    assert_nothing_raised{ @stat.door? }
    assert_boolean(@stat.door?)
  end

  test "door? instance method returns the expected value" do
    assert_true(@stat.door?)
  end

  test "ftype instance method basic functionality" do
    assert_respond_to(@stat, :ftype)
    assert_nothing_raised{ @stat.ftype }
    assert_kind_of(String, @stat.ftype)
  end

  test "ftype instance method returns the expected value" do
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
