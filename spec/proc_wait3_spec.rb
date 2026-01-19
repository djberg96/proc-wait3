# frozen_string_literal: true

##############################################################################
# proc_wait3_spec.rb
#
# Test suite for the Ruby proc-wait3 library. You should run these via the
# 'rake spec' task.
#
# Note that several specs are deliberately wrapped in EINTR rescue handlers
# because I think the Ruby interpreter is sending a signal to the process
# from somewhere in the guts of its core code. Originally I thought this was
# a SIGCHLD but it doesn't always appear to be.
##############################################################################
require 'English'
require 'spec_helper'
require 'rbconfig'

RSpec.describe Process do
  let(:proc_stat_members) {
    %i[
      pid status utime stime maxrss ixrss idrss isrss minflt majflt nswap
      inblock oublock msgsnd msgrcv nsignals nvcsw nivcsw stopped signaled
      exited success coredump exitstatus termsig stopsig
    ]
  }

  before do
    @proc_stat = nil
    @pid = nil
  end

  def call_wait3
    described_class.wait3
  rescue Errno::EINTR
    retry
  end

  def call_wait4(*args)
    described_class.wait4(*args)
  rescue Errno::EINTR
    retry
  end

  def call_waitid(*args)
    described_class.waitid(*args)
  rescue Errno::EINTR
    retry
  end

  example 'version constant is set to expected value' do
    expect(Process::WAIT3_VERSION).to eq('2.1.0')
    expect(Process::WAIT3_VERSION).to be_frozen
  end

  example 'wait3 method is defined' do
    expect(described_class).to respond_to(:wait3)
  end

  example 'wait3 works as expected' do
    @pid = fork { sleep 0.5 }
    expect { call_wait3 }.not_to raise_error
  end

  example 'wait3 returns the expected proc status members' do
    @pid = fork { sleep 0.5 }
    expect { @proc_stat = call_wait3 }.not_to raise_error
    expect(@proc_stat.members).to eq(proc_stat_members)
  end

  example 'wait3 with WNOHANG works as expected' do
    @pid = fork { sleep 0.5 }
    expect { described_class.wait3(Process::WNOHANG) }.not_to raise_error
  end

  example 'wait3 sets and returns $last_status to expected values' do
    @pid = fork { sleep 0.5 }
    call_wait3
    expect($last_status).to be_a(Struct::ProcStat)
    expect($last_status).not_to be_nil
  end

  example 'wait3 sets pid and status members of $?' do
    @pid = fork { sleep 0.5 }
    call_wait3
    expect($CHILD_STATUS).not_to be_nil
  end

  example 'wait3 returns frozen struct' do
    @pid = fork { sleep 0.5 }
    struct = call_wait3
    expect(struct).to be_frozen
  end

  example 'getdtablesize works as expected', :solaris do
    expect(described_class).to respond_to(:getdtablesize)
    expect(described_class.getdtablesize).to be_a(Integer)
    assert(described_class.getdtablesize > 0)
  end

  example 'wait4 method is defined', :skip_hpux do
    expect(described_class).to respond_to(:wait4)
  end

  example 'wait4 requires at least one argument', :skip_hpux do
    expect { call_wait4 }.to raise_error(ArgumentError)
  end

  example 'wait4 works as expected', :skip_hpux do
    @pid = fork { sleep 0.5 }
    expect { @proc_stat = call_wait4(@pid) }.not_to raise_error
    expect(@proc_stat).to be_a(Struct::ProcStat)
  end

  example 'wait4 sets and returns $last_status to expected values', :skip_hpux do
    @pid = fork { sleep 0.5 }
    call_wait4(@pid)
    expect($last_status).to be_a(Struct::ProcStat)
    expect($last_status).not_to be_nil
  end

  example 'wait4 sets pid and status members of $?', :skip_hpux do
    @pid = fork { sleep 0.5 }
    call_wait4(@pid)
    expect($CHILD_STATUS).not_to be_nil
  end

  example 'wait4 returns frozen struct', :skip_hpux do
    @pid = fork { sleep 0.5 }
    struct = call_wait4(@pid)
    expect(struct).to be_frozen
  end

  example 'waitid method is defined', :skip_hpux do
    expect(described_class).to respond_to(:waitid)
  end

  example 'waitid method works as expected', :skip_hpux do
    @pid = fork { sleep 0.5 }
    expect { call_waitid(Process::P_PID, @pid, Process::WEXITED) }.not_to raise_error
  end

  example 'waitid method raises expected errors if wrong argument type is passed', :skip_hpux do
    @pid = fork { sleep 0.5 }
    expect { call_waitid('foo', @pid, Process::WEXITED) }.to raise_error(TypeError)
    expect { call_waitid(Process::P_PID, @pid, 'foo') }.to raise_error(TypeError)
    expect { call_waitid(Process::P_PID, 'foo', Process::WEXITED) }.to raise_error(TypeError)
  end

  example 'waitid method raises expected error if invalid argument is passed', :skip_hpux do
    @pid = fork { sleep 0.5 }
    expect { described_class.waitid(Process::P_PID, 99999999, Process::WEXITED) }.to raise_error(Errno::ECHILD)
  end

  example 'sigsend method is defined', :solaris do
    expect(described_class).to respond_to(:sigsend)
  end

  example 'sigsend works as expected', :solaris do
    @pid = fork { sleep 0.5 }
    expect { described_class.sigsend(Process::P_PID, @pid, 0) }.not_to raise_error
  end

  example 'getrusage method is defined' do
    expect(described_class).to respond_to(:getrusage)
  end

  example 'getrusage works as expected' do
    @pid = fork { sleep 0.5 }

    expect { described_class.getrusage }.not_to raise_error
    expect { described_class.getrusage(true) }.not_to raise_error
  end

  example 'getrusage can get thread info on Linux', :linux do
    expect { described_class.getrusage(Process::RUSAGE_THREAD) }.not_to raise_error
  end

  example 'getrusage returns the expected struct', :linux do
    @pid = fork { sleep 0.5 }
    expect(described_class.getrusage).to be_a(Struct::RUsage)
    expect(described_class.getrusage.stime).to be_a(Float)
    expect(described_class.getrusage.utime).to be_a(Float)
  end

  example 'pause method is defined' do
    expect(described_class).to respond_to(:pause)
  end

  example 'expected constants are defined', :skip_darwin, :skip_bsd do
    expect(Process::WCONTINUED).not_to be_nil
    expect(Process::WEXITED).not_to be_nil
    expect(Process::WNOWAIT).not_to be_nil
    expect(Process::WSTOPPED).not_to be_nil
  end

  example 'expected constant WTRAPPED is defined', :bsd do
    expect(Process::WTRAPPED).not_to be_nil
  end

  example 'expected process type flag constants are defined', :solaris do
    expect(Process::P_ALL).not_to be_nil
    expect(Process::P_CID).not_to be_nil
    expect(Process::P_GID).not_to be_nil
    expect(Process::P_PGID).not_to be_nil
    expect(Process::P_PID).not_to be_nil
    expect(Process::P_SID).not_to be_nil
    expect(Process::P_UID).not_to be_nil
    expect(Process::P_MYID).not_to be_nil
  end

  example 'solaris-specific process type flags are defined on solaris', :solaris do
    expect(Process::P_TASKID).not_to be_nil
    expect(Process::P_PROJID).not_to be_nil
  end

  example 'bsd-specific process type flags are defined on BSD platforms', :bsd do
    expect(Process::P_JAILID).not_to be_nil
  end

  def after
    Process.kill(9, @pid) if @pid
  end
end
