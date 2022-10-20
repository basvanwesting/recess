module Recess
  class CString < FFI::AutoPointer
    def self.release(ptr)
      Binding.free_c_string(ptr)
    end

    def to_s
      @to_s ||= read_string.force_encoding('UTF-8')
    end

    module Binding
      extend FFI::Library
      lib_name = "c_string.#{FFI::Platform::LIBSUFFIX}"
      ffi_lib File.expand_path(lib_name, __dir__)
      attach_function :free_c_string, [CString], :void
    end
  end
end
