module Recess
  class Algorithm
    extend ::FFI::Library
    lib_name = "algorithm.#{::FFI::Platform::LIBSUFFIX}"
    ffi_lib File.expand_path(lib_name, __dir__)
    attach_function :call, [:string, :string, :string], CString, blocking: true
  end
end
