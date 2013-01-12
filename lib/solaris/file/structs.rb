require 'ffi'

module Solaris
  module Structs
    class AclEnt < FFI::Struct
      layout(:a_type, :int, :a_id, :int, :a_perm, :int)
    end

    ACLStruct = Struct.new('ACLStruct', :acl_type, :acl_id, :acl_perm)
  end
end
