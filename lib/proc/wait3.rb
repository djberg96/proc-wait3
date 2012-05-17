require File.join(File.dirname(File.expand_path(__FILE__)), 'wait3', 'functions')
require File.join(File.dirname(File.expand_path(__FILE__)), 'wait3', 'structs')

module Process
  def wait3(flags = 0)
    status = FFI::MemoryPointer.new(:int, 1)
    rusage = RusageStruct.new

    pid = wait3_c(status, flags, rusage)

    if pid < 0
      raise SystemCallError, FFI.errno, "wait3"
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

require 'pp'

pid = fork{ sleep 1; exit 2 }

p Time.now
pp Process.wait3
p $?
