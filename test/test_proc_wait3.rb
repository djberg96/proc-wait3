##################################################################
# test_proc_wait3.rb
#
# Test suite for the Ruby proc-wait3 package. You should run this
# via the 'test' rake task.
##################################################################
require 'rubygems'
gem 'test-unit'

require 'proc/wait3'
require 'test/unit'
require 'rbconfig'

class TC_Proc_Wait3 < Test::Unit::TestCase  
  def self.startup
    @@solaris = Config::CONFIG['host_os'] =~ /sunos|solaris/i
    @@darwin  = Config::CONFIG['host_os'] =~ /darwin|osx/i
    @@hpux    = Config::CONFIG['host_os'] =~ /hpux/i
    @@linux   = Config::CONFIG['host_os'] =~ /linux/i
    @@freebsd = Config::CONFIG['host_os'] =~ /bsd/i
    @@old_ruby = RUBY_VERSION.split('.').last.to_i < 5
  end

  def setup
    @proc_stat = nil
    @proc_stat_members = [
      "pid", "status", "utime", "stime", "maxrss",
      "ixrss", "idrss", "isrss", "minflt", "majflt", "nswap", "inblock",
      "oublock", "msgsnd", "msgrcv", "nsignals", "nvcsw", "nivcsw",
      "stopped", "signaled","exited","success","coredump","exitstatus",
      "termsig", "stopsig"
    ]

    if RUBY_VERSION.to_f >= 1.9
      @proc_stat_members = @proc_stat_members.map{ |e| e.to_sym }
    end
  end

  def test_wait3_version
    assert_equal('1.5.6', Process::WAIT3_VERSION)
  end

  def test_wait3_basic
    assert_respond_to(Process, :wait3)
  end

  def test_wait3_no_args
    pid = fork{ sleep 1 }
    assert_nothing_raised{ Process.wait3 }
  end

  def test_wait3_procstat_members
    pid = fork{ sleep 1 }
    assert_nothing_raised{ @proc_stat = Process.wait3 }
    assert_equal(@proc_stat_members, @proc_stat.members)
  end

  def test_wait3_nohang
    pid = fork{ sleep 1 }
    assert_nothing_raised{ Process.wait3(Process::WNOHANG) }
  end

  def test_getdtablesize
    omit_unless(@@solaris, 'getdtablesize skipped on this platform')

    assert_respond_to(Process, :getdtablesize)
    assert_kind_of(Fixnum, Process.getdtablesize)
    assert(Process.getdtablesize > 0)
  end

  def test_wait4_basic
    omit_if(@@hpux, 'wait4 test skipped on this platform')

    assert_respond_to(Process,:wait4)
    assert_raises(ArgumentError){ Process.wait4 } # Must have at least 1 arg
  end

  def test_wait4_in_action
    omit_if(@@hpux, 'wait4 test skipped on this platform')

    pid = fork{ sleep 1 }
    assert_nothing_raised{ @proc_stat = Process.wait4(pid) }      
    assert_kind_of(Struct::ProcStat, @proc_stat)
  end

  def test_waitid_basic
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')

    assert_respond_to(Process, :waitid)
  end

  def test_waitid
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    pid = fork{ sleep 1 }

    assert_nothing_raised{ Process.waitid(Process::P_PID, pid, Process::WEXITED) }
  end

  def test_waitid_expected_errors
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    pid = fork{ sleep 1 }

    assert_raises(TypeError){ Process.waitid("foo", pid, Process::WEXITED) }
    assert_raises(TypeError){ Process.waitid(Process::P_PID, pid, "foo") }
    assert_raises(TypeError){ Process.waitid(Process::P_PID, "foo", Process::WEXITED) }
    assert_raises(Errno::ECHILD, Errno::EINVAL){ Process.waitid(Process::P_PID, 99999999, Process::WEXITED) }
  end

  def test_sigsend_basic
    omit_unless(@@solaris, 'sigsend test skipped on this platform')
    assert_respond_to(Process, :sigsend)
  end

  def test_sigsend_in_action
    omit_unless(@@solaris, 'sigsend test skipped on this platform')
    pid = fork{ sleep 1 }

    assert_nothing_raised{ Process.sigsend(Process::P_PID, pid, 0) }
  end

  def test_getrusage_basic
    assert_respond_to(Process, :getrusage)
  end

  def test_getrusage_in_action
    pid = fork{ sleep 1 }
    assert_nothing_raised{ Process.getrusage }
    assert_nothing_raised{ Process.getrusage(true) }
    assert_kind_of(Struct::RUsage, Process.getrusage)
    assert_kind_of(Float, Process.getrusage.stime)
    assert_kind_of(Float, Process.getrusage.utime)
  end

  def test_pause
    assert_respond_to(Process, :pause)
  end

  def test_wait_constants
    omit_if(@@darwin || @@freebsd, 'wait constant check skipped on this platform')

    assert_not_nil(Process::WCONTINUED)
    assert_not_nil(Process::WEXITED)
    assert_not_nil(Process::WNOWAIT)
    assert_not_nil(Process::WSTOPPED)

    omit_if(@@linux, 'WTRAPPED constant check skipped on this platform')
    assert_not_nil(Process::WTRAPPED)
  end

  def test_getrlimit
    omit_unless(@@old_ruby, 'getrlimit test skipped on recent versions of Ruby')

    assert_respond_to(Process, :getrlimit)
    assert_nothing_raised{ Process.getrlimit(Process::RLIMIT_CPU) }
    assert_kind_of(Array, Process.getrlimit(Process::RLIMIT_CPU))
    assert_equal(2, Process.getrlimit(Process::RLIMIT_CPU).length)
  end

  def test_setrlimit
    omit_unless(@@old_ruby, 'setrlimit test skipped on recent versions of Ruby')

    assert_respond_to(Process, :setrlimit)
    assert_nothing_raised{
      Process.setrlimit(
        Process::RLIMIT_CPU,
        Process::RLIM_SAVED_CUR,
        Process::RLIM_SAVED_MAX
      )
    }

    assert_nothing_raised{
      Process.setrlimit(Process::RLIMIT_CPU, Process::RLIM_SAVED_CUR)
    }
  end

  # Test to ensure that the various rlimit constants are defined.  Note that
  # as of Ruby 1.8.5 these are defined by Ruby itself, except for the
  # RLIMIT_VMEM constant, which is platform dependent.
  #
  def test_rlimit_constants
    assert_not_nil(Process::RLIMIT_AS)
    assert_not_nil(Process::RLIMIT_CORE)
    assert_not_nil(Process::RLIMIT_CPU)
    assert_not_nil(Process::RLIMIT_DATA)
    assert_not_nil(Process::RLIMIT_FSIZE)
    assert_not_nil(Process::RLIMIT_NOFILE)
    assert_not_nil(Process::RLIMIT_STACK)
    assert_not_nil(Process::RLIM_INFINITY)
  end

  def test_nonstandard_rlimit_constants
    omit_unless(@@old_ruby, 'nonstandard rlimit constant tests skipped on recent versions of Ruby') 
    assert_not_nil(Process::RLIM_SAVED_MAX)
    assert_not_nil(Process::RLIM_SAVED_CUR)
  end

  # This test was added to ensure that these three constants are being
  # defined properly after an issue appeared on Linux with regards to
  # the value accidentally being assigned a negative value.
  #
  def test_rlimit_constants_valid
    omit_unless(@@old_ruby, 'valid rlimit constant tests skipped on recent versions of Ruby')
    assert(Process::RLIM_INFINITY > 0)
    assert(Process::RLIM_SAVED_MAX > 0)
    assert(Process::RLIM_SAVED_CUR > 0)
  end

  def test_process_type_flags
    omit_if(@@linux || @@darwin || @@freebsd, 'process type flag check skipped on this platform')

    assert_not_nil(Process::P_ALL)
    assert_not_nil(Process::P_CID)
    assert_not_nil(Process::P_GID)
    assert_not_nil(Process::P_MYID)
    assert_not_nil(Process::P_PGID)
    assert_not_nil(Process::P_PID)     
    assert_not_nil(Process::P_SID)     
    assert_not_nil(Process::P_UID)
  end

  def test_solaris_process_type_flags
    omit_unless(@@solaris, 'P_TASKID and P_PROJID constant check skipped on this platform')

    assert_not_nil(Process::P_TASKID)
    assert_not_nil(Process::P_PROJID)
  end

  def teardown
    @proc_stat = nil
    @proc_stat_members = nil
  end

  def self.shutdown
    @@solaris  = nil
    @@darwin   = nil
    @@hpux     = nil
    @@linux    = nil
    @@freebsd  = nil
    @@old_ruby = nil
  end
end 
