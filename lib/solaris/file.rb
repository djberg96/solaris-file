require 'ffi'
require File.join(File.dirname(__FILE__), 'file', 'stat')
require File.join(File.dirname(__FILE__), 'file', 'constants')
require File.join(File.dirname(__FILE__), 'file', 'structs')
require File.join(File.dirname(__FILE__), 'file', 'functions')

class File
  include Solaris::Constants
  include Solaris::Functions
  include Solaris::Structs
  extend Solaris::Functions

  # The version of the solaris-file library
  SOLARIS_VERSION = '0.4.0'

  # We redefine the ftype method later.
  class << self
    alias ftype_orig ftype
    remove_method :ftype
  end

  # Reads ACL information for the given file. Returns an array of ACLStruct's
  # that contain three members each:
  #
  # - acl_type (String)
  # - acl_id   (Integer)
  # - acl_perm (Integer)
  #
  # Example:
  #
  #    File.acl_read(file)
  #
  # Returns nil if the file is a trivial file.
  #
  def self.acl_read(file)
    num = acl(file, GETACLCNT, 0, nil)

    if num < 0
      raise SystemCallError.new('acl', FFI.errno)
    end

    arr = nil

    if num != MIN_ACL_ENTRIES
      ptr = FFI::MemoryPointer.new(AclEnt.new, num)

      if acl(file, GETACL, num, ptr) < 0
        raise SystemCallError.new('acl', FFI.errno)
      end

      arr = []

      num.times{ |i|
        ent = AclEnt.new(ptr[i])
        arr << ACLStruct.new(
          acl_type_string(ent[:a_type]), ent[:a_id], ent[:a_perm]
        )
      }
    end

    arr
  end

  # Reads ACL information for the current file. Returns an array of ACLStruct's
  # that contain three members each:
  #
  # - acl_type (String)
  # - acl_id   (Integer)
  # - acl_perm (Integer)
  #
  # Example:
  #
  #    file#acl_read
  #
  # Returns nil if the file is a trivial file.
  #
  def acl_read
    num = facl(fileno, GETACLCNT, 0, nil)

    if num < 0
      raise SystemCallError.new('facl', FFI.errno)
    end

    arr = nil

    if num != MIN_ACL_ENTRIES
      ptr = FFI::MemoryPointer.new(AclEnt.new, num)

      if facl(fileno, GETACL, num, ptr) < 0
        raise SystemCallError.new('facl', FFI.errno)
      end

      arr = []

      num.times{ |i|
        ent = AclEnt.new(ptr[i])
        arr << ACLStruct.new(
          self.class.acl_type_string(ent[:a_type]), ent[:a_id], ent[:a_perm]
        )
      }
    end

    arr
  end

  # Returns a textual representation of the ACL for the given file.
  # If the file is a trivial file, nil is returned instead.
  #
  # Example:
  #
  #  File.acl_read_text(file)
  #
  #  Sample output:
  #
  #  'user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:r--'
  #
  def self.acl_read_text(file)
    num = acl(file, GETACLCNT, 0, nil)

    if num < 0
      raise SystemCallError.new('acl', FFI.errno)
    end

    text = nil

    if num != MIN_ACL_ENTRIES
      ptr = FFI::MemoryPointer.new(AclEnt.new, num)

      if acl(file, GETACL, num, ptr) < 0
        raise SystemCallError.new('acl', FFI.errno)
      end

      text = acltotext(ptr, num)
    end

    text
  end

  # Returns a textual representation of the ACL for the current file.
  # If the file is a trivial file, nil is returned instead.
  #
  # Example:
  #
  #  file#acl_read_text
  #
  #  Sample output:
  #
  #  'user::rw-,user:nobody:r--,group::r--,group:sys:r--,mask:r--,other:r--'
  #
  def acl_read_text
    num = facl(fileno, GETACLCNT, 0, nil)

    if num < 0
      raise SystemCallError.new('facl', FFI.errno)
    end

    text = nil

    if num != MIN_ACL_ENTRIES
      ptr = FFI::MemoryPointer.new(AclEnt.new, num)

      if facl(fileno, GETACL, num, ptr) < 0
        raise SystemCallError.new('acl', FFI.errno)
      end

      text = acltotext(ptr, num)
    end

    text
  end

  # Sets the ACL for the given file using +text+. The +text+ argument is a
  # human readable ACL text string.
  #
  # If the text is invalid then a ArgumentError is raised, and in most
  # cases the offending entry number will be identified.
  #
  # Example:
  #
  #   File.acl_write_text(file, text)
  #
  def self.acl_write_text(file, text)
    pnum = FFI::MemoryPointer.new(:int)
    pwhich = FFI::MemoryPointer.new(:int)

    ptr = aclfromtext(text, pnum)

    if ptr.null?
      raise ArgumentError, "invalid ACL text"
    end

    num = pnum.read_int

    val = aclcheck(ptr, num, pwhich)

    if val != 0
      raise ArgumentError, aclcheck_string(val, pwhich.read_int)
    end

    if acl(file, SETACL, num, ptr) < 0
      raise SystemCallError.new('acl', FFI.errno)
    end

    text
  end

  # Sets the ACL for the current file using +text+. The +text+ argument is a
  # human readable ACL text string.
  #
  # If the text is invalid then a ArgumentError is raised, and in most
  # cases the offending entry number will be identified.
  #
  # Example:
  #
  #   file#acl_write_text(text)
  #
  def acl_write_text(text)
    pnum = FFI::MemoryPointer.new(:int)
    pwhich = FFI::MemoryPointer.new(:int)

    ptr = aclfromtext(text, pnum)

    if ptr.null?
      raise ArgumentError, "invalid ACL text"
    end

    num = pnum.read_int

    val = aclcheck(ptr, num, pwhich)

    if val != 0
      raise ArgumentError, aclcheck_string(val, pwhich.read_int)
    end

    if facl(fileno, SETACL, num, ptr) < 0
      raise SystemCallError.new('facl', FFI.errno)
    end

    text
  end

  # Returns true if the given file is a trivial file, i.e. has no additional ACL
  # entries. Otherwise, it returns false.
  #
  def self.trivial?(file)
    num = acl(file, GETACLCNT, 0, nil)

    raise SystemCallError.new('acl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES
  end

  # Returns true if the current file is a trivial file, i.e. has no additional ACL
  # entries. Otherwise, it returns false.
  #
  def trivial?
    num = facl(fileno, GETACLCNT, 0, nil)

    raise SystemCallError.new('facl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES
  end

  # Returns the number of ACL entries for the given file. Returns 0 if the file
  # is a trivial file.
  #
  def self.acl_count(file)
    num = acl(file, GETACLCNT, 0, nil)

    raise SystemCallError.new('acl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES ? 0 : num
  end

  # Returns the number of ACL entries for the current file. Returns 0 if the file
  # is a trivial file.
  #
  def acl_count
    num = facl(fileno, GETACLCNT, 0, nil)

    raise SystemCallError.new('facl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES ? 0 : num
  end

  # Resolves all symbolic links in the given path.  All "." components are
  # removed, as well as all nonleading ".." components and their preceding
  # directory component.
  #
  # If leading ".." components resolve to the root directory, they are
  # replaced by "/".
  #
  def self.resolvepath(file)
    ptr = FFI::MemoryPointer.new(:char, 1024)

    if resolvepath_c(file, ptr, ptr.size) < 0
      raise SystemCallError.new('resolvepath', FFI.errno)
    end

    ptr.read_string
  end

  # Returns true if the given file is door file, false otherwise.
  #--
  # Door files are special files used for interprocess communication between
  # a client and server.
  #
  def self.door?(file)
    File.stat(file).door?
  end

  # The same as the default ftype method, except that "door" is returned
  # if the file is a door file.
  #
  def self.ftype(file)
    File.stat(file).ftype
  end

  private

  # Convert a numeric error code into a human readable string.
  def self.aclcheck_string(val, int)
    base_string = "Invalid entry: #{int} - "

    case val
      when USER_ERROR
        base_string + "Multiple user entries"
      when GRP_ERROR
        base_string + "Multiple group entries"
      when OTHER_ERROR
        base_string + "Multiple other entries"
      when CLASS_ERROR
        base_string + "Multiple mask entries"
      when DUPLICATE_ERROR
        base_string + "Multiple user or group entries"
      when ENTRY_ERROR
        base_string + "Invalid entry type"
      when MISS_ERROR
        "Missing ACL entries"
      when MEM_ERROR
        "Out of memory"
      else
        "Unknown error"
    end
  end

  # Convert a numeric acl type to a human readable string.
  def self.acl_type_string(num)
    case num
      when USER, USER_OBJ
        "user"
      when GROUP, GROUP_OBJ
        "group"
      when OTHER_OBJ
        "other"
      when CLASS_OBJ
        "mask"
      when DEF_USER, DEF_USER_OBJ
        "defaultuser"
      when DEF_GROUP, DEF_GROUP_OBJ
        "defaultgroup"
      when DEF_OTHER_OBJ
        "defaultother"
      when DEF_CLASS_OBJ
        "defaultmask"
      else
        "unknown"
    end
  end
end
