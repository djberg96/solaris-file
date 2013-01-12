require 'ffi'

class File
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  GETACL = 1
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

  class AclEnt < FFI::Struct
    layout(:a_type, :int, :a_id, :int, :a_perm, :int)
  end

  ACLStruct = Struct.new('ACLStruct', :acl_type, :acl_id, :acl_perm)

  attach_function :acl, [:string, :int, :int, :pointer], :int

  ffi_lib :sec

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

  private

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
