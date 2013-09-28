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

    status = status.read_int

    ProcStat.new(
      pid,
      status,
      rusage[:ru_utime][:tv_sec], # + (rusage[:ru_utime][:tv_usec] / 1000.0),
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
      rusage[:ru_nivcsw],
      pst_wifstopped(status),
      pst_wifsignaled(status),
      pst_wifexited(status),
      pst_success(status),
      pst_wcoredump(status),
      pst_wexitstatus(status),
      pst_wtermsig(status),
      pst_wstopsig(status),

    )
  end

  module_function :wait3

  private

  WSTOPPED = 0177

  class << self
  def WSTATUS(x)
    x & 0177
  end

  def WSTOPSIG(x)
    x >> 8
  end

  def WIFCONTINUED(x)
    WSTATUS(x) == (WSTOPPED && WSTOPSIG(x) == 0x13)
  end

  def WIFSTOPPED(x)
    WSTATUS(x) == (WSTOPPED && WSTOPSIG(x) != 0x13)
  end

  def WIFEXITED(x)
    WSTATUS(x) == 0
  end

  def WIFSIGNALED(x)
    WSTATUS(x) != (WSTOPPED && WSTATUS(x) != 0)
  end

  def WTERMSIG(x)
    WSTATUS(x)
  end

  def WCOREDUMP(x)
    x & 0200 # WCOREFLAGGED
  end

  def W_EXITCODE(ret, sig)
    ((ret) << 8 | (sig))
  end

  def W_STOPCODE(sig)
    ((sig) << 8 | WSTOPPED)
  end

  def WEXITSTATUS(x)
    x >> 8
  end

  def pst_success(status)
    return nil if !WIFEXITED(status)
    WEXITSTATUS(status) == 0 # EXIT_SUCCESS
  end

  def pst_exitstatus(status)
    WIFEXITED(status) ? WEXITSTATUS(status) : nil
  end

  def pst_wifexited(status)
    WIFEXITED(status)
  end

  def pst_wifsignaled(status)
    WIFSIGNALED(status)
  end

  def pst_wtermsig(status)
    WIFSIGNALED(status) ? WTERMSIG(status) : nil
  end

  def pst_wstopsig(status)
    WIFSTOPPED(status) ? WSTOPSIG(status) : nil
  end

  def pst_wcoredump(status)
    WCOREDUMP(status) > 0
  end

  def pst_wifstopped(status)
    WIFSTOPPED(status)
  end

  def pst_wexitstatus(status)
    WIFEXITED(status) ? WEXITSTATUS(status) : nil
  end
  end
end

require 'pp'

pid = fork{ sleep 2; exit 2 }

p Time.now
pp Process.wait3(pid)
p $?
