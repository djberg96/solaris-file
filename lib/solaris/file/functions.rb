require 'ffi'

module Solaris
  module Functions
    extend FFI::Library

    ffi_lib FFI::Library::LIBC

    attach_function :acl, [:string, :int, :int, :pointer], :int
    attach_function :facl, [:int, :int, :int, :pointer], :int
    attach_function :resolvepath_c, :resolvepath, [:string, :pointer, :ulong], :int

    ffi_lib :sec

    attach_function :aclcheck, [:pointer, :int, :pointer], :int
    attach_function :aclfromtext, [:string, :pointer], :pointer
    attach_function :acltotext, [:pointer, :int], :string
  end
end
