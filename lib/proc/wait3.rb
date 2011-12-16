require 'ffi'
require 'pp'

module Process
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  attach_function :wait3, [:pointer, :int, :pointer], :pid_t
  attach_function :wait4, [:pid_t, :pointer, :int, :pointer], :pid_t

  class TimevalStruct < FFI::Struct
    layout(
      :tv_sec, :long,
      :tv_usec, :long
    )
  end

  class RusageStruct < FFI::Struct
    layout(
      :ru_utime,    TimevalStruct,
      :ru_stime,    TimevalStruct,
      :ru_maxrss,   :long,
      :ru_ixrss,    :long,
      :ru_idrss,    :long,
      :ru_isrss,    :long,
      :ru_minflt,   :long,
      :ru_majflt,   :long,
      :ru_nswap,    :long,
      :ru_inblock,  :long,
      :ru_oublock,  :long,
      :ru_msgsnd,   :long,
      :ru_msgrcv,   :long,
      :ru_nsignals, :long,
      :ru_nvcsw,    :long,
      :ru_nivcsw,   :long
    )
  end

  ProcStat = Struct.new('ProcStat', :pid, :status, :utime, :stime, :maxrss,
    :ixrss, :idrss, :isrsss, :minflt, :majflt, :nswap, :inblock, :oublock,
    :msgsnd, :msgrcv, :nsignals, :nvcsw, :nivcsw, :stopped, :signaled,
    :exited, :success, :coredump, :exitstatus, :termsig, :stopsig
  )

  class << self
    alias :wait3_c :wait3
    alias :wait4_c :wait4

    remove_method :wait3
    remove_method :wait4
  end

  def wait3(flags = 0)
    status = FFI::MemoryPointer.new(:int, 1)
    rusage = RusageStruct.new

    pid = wait3_c(status, flags, rusage)

    if pid < 0
      raise "wait3 function failed"
    end

    ProcStat.new(
      pid,
      status.read_int,
      rusage[:ru_utime][:tv_sec], #+ (rusage[:ru_utime][:tv_usec] / 1000.0),
      rusage[:ru_stime][:tv_sec], #+ (rusage[:ru_stime][:tv_usec] / 1000.0),
      rusage[:ru_maxrss],
      rusage[:ru_ixrss],
      rusage[:ru_idrss],
      rusage[:ru_isrss],
      rusage[:ru_minflt],
      rusage[:ru_majflt],
      rusage[:ru_nswap],
      rusage[:ru_inblock],
      rusage[:ru_oublock],
      rusage[:ru_msgsnd],
      rusage[:ru_msgrcv],
      rusage[:ru_nsignals],
      rusage[:ru_nvcsw],
      rusage[:ru_nivcsw]
    )
  end

  module_function :wait3
end

pid = fork{ sleep 1; exit 2 }

p Time.now
p Process.wait3
p $?
