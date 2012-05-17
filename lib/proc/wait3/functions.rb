require 'ffi'

module Process
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  attach_function :wait3_c, :wait3, [:pointer, :int, :pointer], :pid_t
  attach_function :wait4_c, :wait4, [:pid_t, :pointer, :int, :pointer], :pid_t
end
