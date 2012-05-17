module Process
  extend FFI::Library

  ProcStat = Struct.new('ProcStat', :pid, :status, :utime, :stime, :maxrss,
    :ixrss, :idrss, :isrsss, :minflt, :majflt, :nswap, :inblock, :oublock,
    :msgsnd, :msgrcv, :nsignals, :nvcsw, :nivcsw, :stopped, :signaled,
    :exited, :success, :coredump, :exitstatus, :termsig, :stopsig
  )

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
end
