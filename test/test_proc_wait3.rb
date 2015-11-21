##################################################################
# test_proc_wait3.rb
#
# Test suite for the Ruby proc-wait3 package. You should run this
# via the 'test' rake task.
##################################################################
require 'proc/wait3'
require 'test-unit'
require 'rbconfig'

class TC_Proc_Wait3 < Test::Unit::TestCase
  def self.startup
    @@solaris = RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
    @@darwin  = RbConfig::CONFIG['host_os'] =~ /darwin|osx/i
    @@hpux    = RbConfig::CONFIG['host_os'] =~ /hpux/i
    @@linux   = RbConfig::CONFIG['host_os'] =~ /linux/i
    @@freebsd = RbConfig::CONFIG['host_os'] =~ /bsd/i
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

  test "version constant is set to expected value" do
    assert_equal('1.7.3', Process::WAIT3_VERSION)
  end

  test "wait3 method is defined" do
    assert_respond_to(Process, :wait3)
  end

  test "wait3 works as expected" do
    fork{ sleep 0.5 }
    assert_nothing_raised{ Process.wait3 }
  end

  test "wait3 returns the expected proc status membes" do
    fork{ sleep 0.5 }
    assert_nothing_raised{ @proc_stat = Process.wait3 }
    assert_equal(@proc_stat_members, @proc_stat.members)
  end

  test "wait3 with WNOHANG works as expected" do
    fork{ sleep 0.5 }
    assert_nothing_raised{ Process.wait3(Process::WNOHANG) }
  end

  test "wait3 sets and returns $last_status to expected values" do
    fork{ sleep 0.5 }
    Process.wait3
    assert_kind_of(Struct::ProcStat, $last_status)
    assert_not_nil($last_status)
  end

  test "wait3 sets pid and status members of $?" do
    fork{ sleep 0.5 }
    Process.wait3
    assert_not_nil($?)
  end

  test "wait3 returns frozen struct" do
    fork{ sleep 0.5 }
    struct = Process.wait3
    assert_true(struct.frozen?)
  end

  test "getdtablesize works as expected" do
    omit_unless(@@solaris, 'getdtablesize skipped on this platform')

    assert_respond_to(Process, :getdtablesize)
    assert_kind_of(Fixnum, Process.getdtablesize)
    assert(Process.getdtablesize > 0)
  end

  test "wait4 method is defined" do
    omit_if(@@hpux, 'wait4 test skipped on this platform')
    assert_respond_to(Process,:wait4)
  end

  test "wait4 requires at least one argument" do
    assert_raises(ArgumentError){ Process.wait4 }
  end

  test "wait4 works as expected" do
    omit_if(@@hpux, 'wait4 test skipped on this platform')

    pid = fork{ sleep 0.5 }
    assert_nothing_raised{ @proc_stat = Process.wait4(pid) }
    assert_kind_of(Struct::ProcStat, @proc_stat)
  end

  test "wait4 sets and returns $last_status to expected values" do
    pid = fork{ sleep 0.5 }
    Process.wait4(pid)
    assert_kind_of(Struct::ProcStat, $last_status)
    assert_not_nil($last_status)
  end

  test "wait4 sets pid and status members of $?" do
    pid = fork{ sleep 0.5 }
    Process.wait4(pid)
    assert_not_nil($?)
  end

  test "wait4 returns frozen struct" do
    pid = fork{ sleep 0.5 }
    struct = Process.wait4(pid)
    assert_true(struct.frozen?)
  end

  test "waitid method is defined" do
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    assert_respond_to(Process, :waitid)
  end

  test "waitid method works as expected" do
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    pid = fork{ sleep 0.5 }
    assert_nothing_raised{ Process.waitid(Process::P_PID, pid, Process::WEXITED) }
  end

  test "waitid method raises expected errors if wrong argument type is passed" do
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    pid = fork{ sleep 0.5 }
    assert_raises(TypeError){ Process.waitid("foo", pid, Process::WEXITED) }
    assert_raises(TypeError){ Process.waitid(Process::P_PID, pid, "foo") }
    assert_raises(TypeError){ Process.waitid(Process::P_PID, "foo", Process::WEXITED) }
  end

  test "waitid method raises expected error if invalid argument is passed" do
    omit_if(@@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform')
    fork{ sleep 0.5 }
    assert_raises(Errno::ECHILD, Errno::EINVAL){ Process.waitid(Process::P_PID, 99999999, Process::WEXITED) }
  end

  test "sigsend method is defined" do
    omit_unless(@@solaris, 'sigsend test skipped on this platform')
    assert_respond_to(Process, :sigsend)
  end

  test "sigsend works as expected" do
    omit_unless(@@solaris, 'sigsend test skipped on this platform')
    pid = fork{ sleep 0.5 }
    assert_nothing_raised{ Process.sigsend(Process::P_PID, pid, 0) }
  end

  test "getrusage method is defined" do
    assert_respond_to(Process, :getrusage)
  end

  test "getrusage works as expected" do
    fork{ sleep 0.5 }
    assert_nothing_raised{ Process.getrusage }
    assert_nothing_raised{ Process.getrusage(true) }
  end

  test "getrusage can get thread info on Linux" do
    omit_unless(@@linux)
    assert_nothing_raised{ Process.getrusage(Process::RUSAGE_THREAD) }
  end

  test "getrusage returns the expected struct" do
    fork{ sleep 0.5 }
    assert_kind_of(Struct::RUsage, Process.getrusage)
    assert_kind_of(Float, Process.getrusage.stime)
    assert_kind_of(Float, Process.getrusage.utime)
  end

  test "pause method is defined" do
    assert_respond_to(Process, :pause)
  end

  test "expected constants are defined" do
    omit_if(@@darwin || @@freebsd, 'wait constant check skipped on this platform')

    assert_not_nil(Process::WCONTINUED)
    assert_not_nil(Process::WEXITED)
    assert_not_nil(Process::WNOWAIT)
    assert_not_nil(Process::WSTOPPED)

    omit_if(@@linux, 'WTRAPPED constant check skipped on this platform')
    assert_not_nil(Process::WTRAPPED)
  end

  test "expected process type flag constants are defined" do
    omit_if(@@linux || @@darwin || @@freebsd, 'process type flag check skipped on this platform')

    assert_not_nil(Process::P_ALL)
    assert_not_nil(Process::P_CID)
    assert_not_nil(Process::P_GID)
    assert_not_nil(Process::P_MYID) unless @@solaris
    assert_not_nil(Process::P_PGID)
    assert_not_nil(Process::P_PID)
    assert_not_nil(Process::P_SID)
    assert_not_nil(Process::P_UID)
  end

  test "solaris-specific process type flags are defined on solaris" do
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
  end
end
