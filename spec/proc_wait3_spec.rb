#######################################################################
# proc_wait3_spec.rb
#
# Test suite for the Ruby proc-wait3 library. You should run these
# via the 'rake spec' task.
#######################################################################
require 'proc/wait3'
require 'rspec'
require 'rbconfig'

RSpec.describe Process do
  let(:solaris) { RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i }
  let(:darwin) { RbConfig::CONFIG['host_os'] =~ /darwin|osx/i }
  let(:hpux) { RbConfig::CONFIG['host_os'] =~ /hpux/i }
  let(:linux) { RbConfig::CONFIG['host_os'] =~ /linux/i }
  let(:freebsd) { RbConfig::CONFIG['host_os'] =~ /bsd/i }

  before do
    @proc_stat = nil
    @proc_stat_members = %i[
      pid status utime stime maxrss ixrss idrss isrss minflt majflt nswap
      inblock oublock msgsnd msgrcv nsignals nvcsw nivcsw stopped signaled
      exited success coredump exitstatus termsig stopsig
    ]
  end

  example "version constant is set to expected value" do
    expect(Process::WAIT3_VERSION).to eq('1.9.0')
    expect(Process::WAIT3_VERSION).to be_frozen
  end

=begin
  example "wait3 method is defined" do
    expect(Process).to respond_to(:wait3)
  end

  example "wait3 works as expected" do
    fork{ sleep 0.5 }
    expect{ Process.wait3 }.not_to raise_error
  end

  example "wait3 returns the expected proc status membes" do
    fork{ sleep 0.5 }
    expect{ @proc_stat = Process.wait3 }.not_to raise_error
    expect( @proc_stat.members).to eq(@proc_stat_members)
  end

  example "wait3 with WNOHANG works as expected" do
    fork{ sleep 0.5 }
    expect{ Process.wait3(Process::WNOHANG) }.not_to raise_error
  end

  example "wait3 sets and returns $last_status to expected values" do
    fork{ sleep 0.5 }
    Process.wait3
    expect( $last_status).to be_kind_of(Struct::ProcStat)
    expect($last_status).not_to be_nil
  end

  example "wait3 sets pid and status members of $?" do
    fork{ sleep 0.5 }
    Process.wait3
    expect($?).not_to be_nil
  end

  example "wait3 returns frozen struct" do
    fork{ sleep 0.5 }
    struct = Process.wait3
    expect(struct.frozen?).to be true
  end

  example "getdtablesize works as expected" do
    skip unless @@solaris, 'getdtablesize skipped on this platform'

    expect(Process).to respond_to(:getdtablesize)
    expect( Process.getdtablesize).to be_kind_of(Fixnum)
    assert(Process.getdtablesize > 0)
  end

  example "wait4 method is defined" do
    skip if @@hpux, 'wait4 test skipped on this platform'
    assert_respond_to(Process,:wait4)
  end

  example "wait4 requires at least one argument" do
    expect{ Process.wait4 }.to raise_error(ArgumentError)
  end

  example "wait4 works as expected" do
    skip if @@hpux, 'wait4 test skipped on this platform'

    pid = fork{ sleep 0.5 }
    expect{ @proc_stat = Process.wait4(pid) }.not_to raise_error
    expect( @proc_stat).to be_kind_of(Struct::ProcStat)
  end

  example "wait4 sets and returns $last_status to expected values" do
    pid = fork{ sleep 0.5 }
    Process.wait4(pid)
    expect( $last_status).to be_kind_of(Struct::ProcStat)
    expect($last_status).not_to be_nil
  end

  example "wait4 sets pid and status members of $?" do
    pid = fork{ sleep 0.5 }
    Process.wait4(pid)
    expect($?).not_to be_nil
  end

  example "wait4 returns frozen struct" do
    pid = fork{ sleep 0.5 }
    struct = Process.wait4(pid)
    expect(struct.frozen?).to be true
  end

  example "waitid method is defined" do
    skip if @@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform'
    expect(Process).to respond_to(:waitid)
  end

  example "waitid method works as expected" do
    skip if @@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform'
    pid = fork{ sleep 0.5 }
    expect{ Process.waitid(Process::P_PID, pid, Process::WEXITED) }.not_to raise_error
  end

  example "waitid method raises expected errors if wrong argument type is passed" do
    skip if @@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform'
    pid = fork{ sleep 0.5 }
    expect{ Process.waitid("foo", pid, Process::WEXITED) }.to raise_error(TypeError)
    expect{ Process.waitid(Process::P_PID, pid, "foo") }.to raise_error(TypeError)
    expect{ Process.waitid(Process::P_PID, "foo", Process::WEXITED) }.to raise_error(TypeError)
  end

  example "waitid method raises expected error if invalid argument is passed" do
    skip if @@hpux || @@darwin || @@freebsd, 'waitid test skipped on this platform'
    fork{ sleep 0.5 }
    expect{ Process.waitid(Process::P_PID, 99999999, Process::WEXITED) }.to raise_error(Errno::ECHILD, Errno::EINVAL)
  end

  example "sigsend method is defined" do
    skip unless @@solaris, 'sigsend test skipped on this platform'
    expect(Process).to respond_to(:sigsend)
  end

  example "sigsend works as expected" do
    skip unless @@solaris, 'sigsend test skipped on this platform'
    pid = fork{ sleep 0.5 }
    expect{ Process.sigsend(Process::P_PID, pid, 0) }.not_to raise_error
  end

  example "getrusage method is defined" do
    expect(Process).to respond_to(:getrusage)
  end

  example "getrusage works as expected" do
    fork{ sleep 0.5 }
    expect{ Process.getrusage }.not_to raise_error
    expect{ Process.getrusage(true) }.not_to raise_error
  end

  example "getrusage can get thread info on Linux" do
    skip unless @@linux
    expect{ Process.getrusage(Process::RUSAGE_THREAD) }.not_to raise_error
  end

  example "getrusage returns the expected struct" do
    fork{ sleep 0.5 }
    expect( Process.getrusage).to be_kind_of(Struct::RUsage)
    expect( Process.getrusage.stime).to be_kind_of(Float)
    expect( Process.getrusage.utime).to be_kind_of(Float)
  end

  example "pause method is defined" do
    expect(Process).to respond_to(:pause)
  end

  example "expected constants are defined" do
    skip if @@darwin || @@freebsd, 'wait constant check skipped on this platform'

    expect(Process::WCONTINUED).not_to be_nil
    expect(Process::WEXITED).not_to be_nil
    expect(Process::WNOWAIT).not_to be_nil
    expect(Process::WSTOPPED).not_to be_nil

    skip if @@linux, 'WTRAPPED constant check skipped on this platform'
    expect(Process::WTRAPPED).not_to be_nil
  end

  example "expected process type flag constants are defined" do
    skip if @@linux || @@darwin || @@freebsd, 'process type flag check skipped on this platform'

    expect(Process::P_ALL).not_to be_nil
    expect(Process::P_CID).not_to be_nil
    expect(Process::P_GID).not_to be_nil
    expect(Process::P_MYID).not_to be_nil unless @@solaris
    expect(Process::P_PGID).not_to be_nil
    expect(Process::P_PID).not_to be_nil
    expect(Process::P_SID).not_to be_nil
    expect(Process::P_UID).not_to be_nil
  end

  example "solaris-specific process type flags are defined on solaris" do
    skip unless @@solaris, 'P_TASKID and P_PROJID constant check skipped on this platform'

    expect(Process::P_TASKID).not_to be_nil
    expect(Process::P_PROJID).not_to be_nil
  end
=end
end
