require 'ffi'

class File
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  GETACL = 1
  SETACL = 2
  GETACLCNT = 3
  MIN_ACL_ENTRIES = 4

  USER_OBJ      = (0x01)
  USER          = (0x02)
  GROUP_OBJ     = (0x04)
  GROUP         = (0x08)
  CLASS_OBJ     = (0x10)
  OTHER_OBJ     = (0x20)
  ACL_DEFAULT   = (0x1000)
  DEF_USER_OBJ  = (ACL_DEFAULT | USER_OBJ)
  DEF_USER      = (ACL_DEFAULT | USER)
  DEF_GROUP_OBJ = (ACL_DEFAULT | GROUP_OBJ)
  DEF_GROUP     = (ACL_DEFAULT | GROUP)
  DEF_CLASS_OBJ = (ACL_DEFAULT | CLASS_OBJ)
  DEF_OTHER_OBJ = (ACL_DEFAULT | OTHER_OBJ)

  GRP_ERROR       = 1
  USER_ERROR      = 2
  OTHER_ERROR     = 3
  CLASS_ERROR     = 4
  DUPLICATE_ERROR = 5
  MISS_ERROR      = 6
  MEM_ERROR       = 7
  ENTRY_ERROR     = 8

  class AclEnt < FFI::Struct
    layout(:a_type, :int, :a_id, :int, :a_perm, :int)
  end

  ACLStruct = Struct.new('ACLStruct', :acl_type, :acl_id, :acl_perm)

  attach_function :acl, [:string, :int, :int, :pointer], :int

  ffi_lib :sec

  attach_function :aclcheck, [:pointer, :int, :pointer], :int
  attach_function :aclfromtext, [:string, :pointer], :pointer
  attach_function :acltotext, [:pointer, :int], :string

  # The version of the solaris-file library
  SOLARIS_VERSION = '0.4.0'

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

  def self.trivial?(file)
    num = acl(file, GETACLCNT, 0, nil)

    raise SystemCallError.new('acl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES
  end

  def self.acl_count(file)
    num = acl(file, GETACLCNT, 0, nil)

    raise SystemCallError.new('acl', FFI.errno) if num < 0

    num == MIN_ACL_ENTRIES ? 0 : num
  end

  private

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
