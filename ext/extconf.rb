########################################################
# Use the mkmf.rb file that I provide, so I can use the
# have_enum_member method
########################################################
require 'mkmf'

dir_config('proc-wait3')

# We need this for older versions of Ruby.
def have_const(const, header = nil, opt = "", &b)
  checking_for const do
    header = cpp_include(header)
    if try_compile(<<"SRC", opt, &b)
#{COMMON_HEADERS}
#{header}
/* top */
static int t = #{const};
SRC
     $defs.push(
        format(
          "-DHAVE_CONST_%s",
          const.strip.upcase.tr_s("^A-Z0-9_", "_")
        )
      )
      true
    else
      false
    end
  end
end

have_header('wait.h')

# wait3 is mandatory.
unless have_func('wait3')
  STDERR.puts 'wait3() function not found'
  exit
end

# Yay, Linux
have_func('str2sig')
have_func('strlcpy')

# wait4, waitid, etc, are optional (HPUX, et al)
have_func('wait4')
have_func('waitid')
have_func('sigsend')
have_func('getrusage')
have_func('getdtablesize')

have_struct_member('struct siginfo', 'si_fd', 'signal.h')
have_struct_member('struct siginfo', 'si_trapno', 'signal.h')
have_struct_member('struct siginfo', 'si_pc', 'signal.h')
have_struct_member('struct siginfo', 'si_sysarg', 'signal.h')
have_struct_member('struct siginfo', 'si_mstate', 'signal.h')
have_struct_member('struct siginfo', 'si_faddr', 'signal.h')
have_struct_member('struct siginfo', 'si_syscall', 'signal.h')
have_struct_member('struct siginfo', 'si_nsysarg', 'signal.h')
have_struct_member('struct siginfo', 'si_fault', 'signal.h')
have_struct_member('struct siginfo', 'si_tstamp', 'signal.h')
have_struct_member('struct siginfo', 'si_utime', 'signal.h')
have_struct_member('struct siginfo', 'si_status', 'signal.h')
have_struct_member('struct siginfo', 'si_stime', 'signal.h')

have_const('P_CID', 'signal.h')
have_const('P_GID', 'signal.h')
have_const('P_MYID', 'signal.h')
have_const('P_SID', 'signal.h')
have_const('P_UID', 'signal.h')

have_const('P_ALL', 'signal.h') || have_const('P_ALL', 'sys/wait.h')
have_const('P_PGID', 'signal.h') || have_const('P_PGID', 'sys/wait.h')
have_const('P_PID', 'signal.h') || have_const('P_PID', 'sys/wait.h')

# These are only supported by Solaris 8 and later afaik
have_const('P_PROJID', 'signal.h')
have_const('P_TASKID', 'signal.h')

create_makefile('proc/wait3', 'proc')
