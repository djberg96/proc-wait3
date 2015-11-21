#include <ruby.h>
#include <string.h>
#include <unistd.h>

/* Debian */
#ifdef HAVE_SYS_RESOURCE_H
#include <sys/resource.h>
#endif

#ifdef HAVE_WAIT_H
#include <wait.h>
#else
#include <sys/resource.h>
#include <sys/wait.h>
#endif

#if defined(HAVE_WAITID) || defined(HAVE_SIGSET)
#include <signal.h>
#endif

#ifndef SIG2STR_MAX
#define SIG2STR_MAX 32
#endif

/* Ruby 1.9.x */
#ifndef RSTRING_PTR
#define RSTRING_PTR(v) (RSTRING(v)->ptr)
#define RSTRING_LEN(v) (RSTRING(v)->len)
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(v) (RARRAY(v)->ptr)
#define RARRAY_LEN(v) (RARRAY(v)->len)
#endif

/* Copied from process.c in Ruby 1.8.5 */
#ifndef RUBY_HAS_RLIMIT
#if SIZEOF_RLIM_T == SIZEOF_INT
# define RLIM2NUM(v) UINT2NUM(v)
# define NUM2RLIM(v) NUM2UINT(v)
#elif SIZEOF_RLIM_T == SIZEOF_LONG
# define RLIM2NUM(v) ULONG2NUM(v)
# define NUM2RLIM(v) NUM2ULONG(v)
#elif SIZEOF_RLIM_T == SIZEOF_LONG_LONG
# define RLIM2NUM(v) ULL2NUM(v)
# define NUM2RLIM(v) NUM2ULL(v)
#endif
#endif

VALUE v_last_status;
VALUE v_procstat_struct, v_siginfo_struct, v_usage_struct;

static void sigproc(int signum);

/*
 * Returns true if this process is stopped. This is only returned
 * returned if the corresponding wait() call had the WUNTRACED flag
 * set.
 */
static VALUE pst_wifstopped(int status)
{
   if(WIFSTOPPED(status))
      return Qtrue;
   else
      return Qfalse;
}

/*
 * Returns true if _stat_ terminated because of an uncaught signal.
 */
static VALUE pst_wifsignaled(int status)
{
  if (WIFSIGNALED(status))
	  return Qtrue;
  else
    return Qfalse;
}

/*
 * Returns true if _stat_ exited normally (for example using an exit()
 * call or finishing the program).
 */
static VALUE pst_wifexited(int status)
{
  if (WIFEXITED(status))
    return Qtrue;
  else
    return Qfalse;
}

/*
 * Returns true if _stat_ is successful, false otherwise.
 * Returns nil if exited? is not true.
 */
static VALUE pst_success_p(int status)
{
  if (!WIFEXITED(status))
    return Qnil;

  return WEXITSTATUS(status) == EXIT_SUCCESS ? Qtrue : Qfalse;
}

/*
 * Returns true if _stat_ generated a coredump when it terminated. Not
 * available on all platforms.
 */
static VALUE pst_wcoredump(int status)
{
#ifdef WCOREDUMP
  if (WCOREDUMP(status))
    return Qtrue;
  else
    return Qfalse;
#else
  return Qfalse;
#endif
}

/*
 * Returns the least significant eight bits of the return code of
 * _stat_. Only available if exited? is true.
 */
static VALUE pst_wexitstatus(int status)
{
  if (WIFEXITED(status))
    return INT2NUM(WEXITSTATUS(status));

  return Qnil;
}

/*
 * Returns the number of the signal that caused _stat_ to terminate
 * (or nil if self was not terminated by an uncaught signal).
 */
static VALUE pst_wtermsig(int status)
{
  if (WIFSIGNALED(status))
    return INT2NUM(WTERMSIG(status));

  return Qnil;
}

/*
 * Returns the number of the signal that caused _stat_ to stop (or nil
 * if self is not stopped).
 */
static VALUE pst_wstopsig(int status)
{
  if(WIFSTOPPED(status))
    return INT2NUM(WSTOPSIG(status));

  return Qnil;
}

/*
 * call-seq:
 *    Process.wait3(flags=nil)
 *
 * Delays its caller until a signal is received or one of its child processes
 * terminates or stops due to tracing.
 *
 * The return value is a ProcStat structure. The special global $? is also
 * set. Raises a SystemError if there are no child processes.
 */
static VALUE proc_wait3(int argc, VALUE *argv, VALUE mod){
   int status;
   int flags = 0;
   struct rusage r;
   pid_t pid;
   VALUE v_flags = Qnil;

   rb_scan_args(argc,argv,"01",&v_flags);

   if(Qnil != v_flags){
      flags = NUM2INT(v_flags);
   }

   pid = wait3(&status, flags, &r);

   if(pid < 0){
      rb_sys_fail("wait3");
   }
   else if(pid > 0){
      v_last_status = rb_struct_new(v_procstat_struct,
         INT2FIX(pid),
         INT2FIX(status),
         INT2FIX(r.ru_utime.tv_sec + (r.ru_utime.tv_usec/1e6)),
         INT2FIX(r.ru_stime.tv_sec + (r.ru_stime.tv_usec/1e6)),
         INT2FIX(r.ru_maxrss),
         INT2FIX(r.ru_ixrss),
         INT2FIX(r.ru_idrss),
         INT2FIX(r.ru_isrss),
         INT2FIX(r.ru_minflt),
         INT2FIX(r.ru_majflt),
         INT2FIX(r.ru_nswap),
         INT2FIX(r.ru_inblock),
         INT2FIX(r.ru_oublock),
         INT2FIX(r.ru_msgsnd),
         INT2FIX(r.ru_msgrcv),
         INT2FIX(r.ru_nsignals),
         INT2FIX(r.ru_nvcsw),
         INT2FIX(r.ru_nivcsw),
         pst_wifstopped(status),
         pst_wifsignaled(status),
         pst_wifexited(status),
         pst_success_p(status),
         pst_wcoredump(status),
         pst_wexitstatus(status),
         pst_wtermsig(status),
         pst_wstopsig(status)
      );

      rb_last_status_set(status, pid);
      OBJ_FREEZE(v_last_status);

      return v_last_status;
   }
   else{
      return Qnil;
   }
}

#ifdef HAVE_WAIT4
/*
 * call-seq:
 *    Process.wait4(pid, flags=0)
 *
 * Waits for the given child process to exit. Returns a ProcStat structure.
 * Also sets the $? special global variable.
 *
 * This method is not supported on all platforms.
 *
 * Some +flags+ are not supported on all platforms.
 */
static VALUE proc_wait4(int argc, VALUE *argv, VALUE mod){
   int status;
   int flags = 0;
   struct rusage r;
   pid_t pid;
   VALUE v_pid;
   VALUE v_flags = Qnil;

   rb_scan_args(argc, argv, "11", &v_pid, &v_flags);

   pid = NUM2INT(v_pid);

   if(RTEST(v_flags))
      flags = NUM2INT(v_flags);

   pid = wait4(pid, &status, flags, &r);

   if(pid < 0){
      rb_sys_fail("wait4");
   }
   else if(pid > 0){
      v_last_status = rb_struct_new(v_procstat_struct,
         INT2FIX(pid),
         INT2FIX(status),
         INT2FIX(r.ru_utime.tv_sec + (r.ru_utime.tv_usec/1e6)),
         INT2FIX(r.ru_stime.tv_sec + (r.ru_stime.tv_usec/1e6)),
         INT2FIX(r.ru_maxrss),
         INT2FIX(r.ru_ixrss),
         INT2FIX(r.ru_idrss),
         INT2FIX(r.ru_isrss),
         INT2FIX(r.ru_minflt),
         INT2FIX(r.ru_majflt),
         INT2FIX(r.ru_nswap),
         INT2FIX(r.ru_inblock),
         INT2FIX(r.ru_oublock),
         INT2FIX(r.ru_msgsnd),
         INT2FIX(r.ru_msgrcv),
         INT2FIX(r.ru_nsignals),
         INT2FIX(r.ru_nvcsw),
         INT2FIX(r.ru_nivcsw),
         pst_wifstopped(status),
         pst_wifsignaled(status),
         pst_wifexited(status),
         pst_success_p(status),
         pst_wcoredump(status),
         pst_wexitstatus(status),
         pst_wtermsig(status),
         pst_wstopsig(status)
      );

      rb_last_status_set(status, pid);
      OBJ_FREEZE(v_last_status);

      return v_last_status;
   }
   else{
      return Qnil;
   }
}
#endif

#ifdef HAVE_WAITID
/*
 * call-seq:
 *    Process.waitid(id_type, id_num=nil, options=nil)
 *
 * Suspends the calling process until one of its children changes state,
 * returning immediately if a child process changed state prior to the call.
 * The state of a child process will change if it terminates, stops because
 * of a signal, becomes trapped or reaches a breakpoint.
 *
 * The +id_num+ argument corresponds to a pid or pgid, depending on the value
 * of +id_type+, which may be Process::P_PID, Process::P_GID or Process::P_ALL.
 * If Process::P_ALL, then +id_num+ is ignored.
 *
 * The options argument is used to specify which state changes are to be
 * waited for.  It is constructed from the bitwise-OR of one or more of the
 * following constants:
 *
 * Process::WCONTINUED
 * Process::WEXITED
 * Process::WNOHANG
 * Process::WNOWAIT
 * Process::WSTOPPED
 * Process::WTRAPPED
 *
 * Not all of these constants are supported on all platforms.
 *
 * If Process::WNOHANG is set as an option, this method will return
 * immediately, whether or not a child has changed state.
 *
 * Calling this method with an +id_type+ of Process::P_ALL and the options set
 * to 'Process::WEXITED | Process::WTRAPPED' is equivalent to calling
 * Process.wait.
 *
 * Returns a Proc::SigInfo struct and sets $?.
 *
 * Not supported on all platforms.
 */
static VALUE proc_waitid(int argc, VALUE* argv, VALUE mod){
   VALUE v_type, v_id, v_options;
   siginfo_t infop;
   idtype_t idtype;
   id_t id = 0;
   int options = 0;

   rb_scan_args(argc, argv, "12", &v_type, &v_id, &v_options);

   idtype = NUM2INT(v_type);

   if(RTEST(v_id))
      id = NUM2INT(v_id);

   if(RTEST(v_options))
      options = NUM2INT(v_options);

   /* The Linux man page for waitid() says to zero out the pid field and check
    * its value after the call to waitid() to detect if there were children in
    * a waitable state or not (which we do later, below).  Other platforms
    * simply check the infop.si_signo struct member against SI_NOINFO.
    */
#ifndef SI_NOINFO
   infop.si_pid = 0;
#endif

   if(waitid(idtype, id, &infop, options) == -1)
      rb_sys_fail("waitid");

    /* If the si_code struct member returns SI_NOINFO, or the si_pid member
     * is still set to 0 after the call to waitid(), then only the si_signo
     * member of the struct is meaningful.  In that case, we'll set all other
     * members to nil.  Even if this condition doesn't arise, many of the
     * SigInfo struct members may still be nil, depending on the value of
     * si_signo.
     *
     * See Rich Teer's "Solaris Systems Programming", p 755 ff.
     */

#ifdef SI_NOINFO
   if(infop.si_code == SI_NOINFO){
#else
   if(infop.si_pid == 0){
#endif
      v_last_status = rb_struct_new(v_siginfo_struct,
         INT2FIX(infop.si_signo),
         INT2FIX(infop.si_errno),
         Qnil, Qnil, Qnil, Qnil, Qnil, Qnil, /* code, pid, uid, utime, status, stime */
#ifdef HAVE_ST_SI_TRAPNO
         Qnil,
#endif
#ifdef HAVE_ST_SI_PC
         Qnil,
#endif
         Qnil, Qnil, /* fd, band */
#ifdef HAVE_ST_SI_FADDR
         Qnil,
#endif
#ifdef HAVE_ST_SI_TSTAMP
         Qnil,
#endif
#ifdef HAVE_ST_SI_SYSCALL
         Qnil,
#endif
#ifdef HAVE_ST_SI_NSYSARG
         Qnil,
#endif
#ifdef HAVE_ST_SI_FAULT
         Qnil,
#endif
#ifdef HAVE_ST_SI_SYSARG
         Qnil,
#endif
#ifdef HAVE_ST_SI_MSTATE
         Qnil,
#endif
         Qnil  /* entity */
      );
   }
   else{
      VALUE v_utime = Qnil, v_status = Qnil, v_stime = Qnil;
#ifdef HAVE_ST_SI_FD
      VALUE v_fd = Qnil;
#endif
#ifdef HAVE_ST_SI_TRAPNO
      VALUE v_trapno = Qnil;
#endif
#ifdef HAVE_ST_SI_PC
      VALUE v_pc = Qnil;
#endif
#ifdef HAVE_ST_SI_FADDR
      VALUE v_addr = Qnil;
#endif
#ifdef HAVE_ST_SI_TSTAMP
      VALUE v_time = Qnil;
#endif
#ifdef HAVE_ST_SI_SYSCALL
      VALUE v_syscall = Qnil;
#endif
#ifdef HAVE_ST_SI_NSYSARG
      VALUE v_nsysarg = Qnil;
#endif
#ifdef HAVE_ST_SI_FAULT
      VALUE v_fault = Qnil;
#endif
#ifdef HAVE_ST_SI_SYSARG
      VALUE v_sysarg = Qnil;
#endif
#ifdef HAVE_ST_SI_MSTATE
      VALUE v_state = Qnil;
#endif
      VALUE v_band = Qnil, v_entity = Qnil;
      int sig = infop.si_signo;
      int code = infop.si_code;

#if defined(HAVE_ST_SI_SYSARG) || defined(HAVE_ST_SI_MSTATE)
      int i = 0;
#endif

      /* If Process.waitid returns because a child process was found that
       * satisfies the conditions indicated by +id_type+ and +options+, then
       * the si_signo struct member will always be SIGCHLD.
       */
      if(sig == SIGCHLD){
#ifdef HAVE_ST_SI_UTIME
         v_utime  = ULL2NUM(infop.si_utime);
#endif
#ifdef HAVE_ST_SI_STATUS
         v_status = ULL2NUM(infop.si_status);
#endif
#ifdef HAVE_ST_SI_STIME
         v_stime  = ULL2NUM(infop.si_stime);
#endif
      }

      if(sig == SIGBUS || sig == SIGFPE || sig == SIGILL || sig == SIGSEGV ||
         sig == SIGTRAP)
      {
#ifdef HAVE_ST_SI_TRAPNO
         v_trapno = INT2FIX(infop.si_trapno);
#endif
#ifdef HAVE_ST_SI_PC
         v_pc = INT2FIX(infop.si_pc);
#endif
      }

      if(sig == SIGXFSZ){
#ifdef HAVE_ST_SI_FD
         v_fd = INT2FIX(infop.si_fd);
#endif
         if(code == POLL_IN || code == POLL_OUT || code == POLL_MSG){
            v_band = LONG2FIX(infop.si_band);
         }
      }

      if(sig == SIGPROF){
#ifdef HAVE_ST_SI_SYSARG
         int ssize = sizeof(infop.si_sysarg) / sizeof(infop.si_sysarg[0]);
         v_sysarg  = rb_ary_new();

         for(i = 0; i < ssize; i++)
            rb_ary_push(v_sysarg, LONG2FIX(infop.si_sysarg[i]));
#endif
#ifdef HAVE_ST_SI_MSTATE
         int msize = sizeof(infop.si_mstate) / sizeof(infop.si_mstate[0]);
         v_state  = rb_ary_new();

         for(i = 0; i < msize; i++)
            rb_ary_push(v_state, INT2FIX(infop.si_mstate[i]));
#endif
#ifdef HAVE_ST_SI_FADDR
         v_addr   = INT2FIX(infop.si_faddr);
#endif
#ifdef HAVE_ST_SI_SYSCALL
         v_syscall = INT2FIX(infop.si_syscall);
#endif
#ifdef HAVE_ST_SI_NSYSARG
         v_nsysarg = INT2FIX(infop.si_nsysarg);
#endif
#ifdef HAVE_ST_SI_FAULT
         v_fault   = INT2FIX(infop.si_fault);
#endif
#ifdef HAVE_ST_SI_TSTAMP
         v_time = rb_time_new(infop.si_tstamp.tv_sec,infop.si_tstamp.tv_nsec);
#endif
      }

#ifdef SIGXRES
      if(sig == SIGXRES){
         v_entity = INT2FIX(infop.si_entity);
      }
#endif

      v_last_status = rb_struct_new(v_siginfo_struct,
         INT2FIX(infop.si_signo),   // Probably SIGCHLD
         INT2FIX(infop.si_errno),   // 0 means no error
         INT2FIX(infop.si_code),    // Should be anything but SI_NOINFO
         INT2FIX(infop.si_pid),     // Real PID that sent the signal
         INT2FIX(infop.si_uid),     // Real UID of process that sent signal
         v_utime,
         v_status,
         v_stime,
#ifdef HAVE_ST_SI_TRAPNO
         v_trapno,
#endif
#ifdef HAVE_ST_SI_PC
         v_pc,
#endif
#ifdef HAVE_ST_SI_FD
         v_fd,
#endif
         v_band,
#ifdef HAVE_ST_SI_FADDR
         v_addr,
#endif
#ifdef HAVE_ST_SI_TSTAMP
         v_time,
#endif
#ifdef HAVE_ST_SI_SYSCALL
         v_syscall,
#endif
#ifdef HAVE_ST_SI_NSYSARG
         v_nsysarg,
#endif
#ifdef HAVE_ST_SI_FAULT
         v_fault,
#endif
#ifdef HAVE_ST_SI_SYSARG
         v_sysarg,
#endif
#ifdef HAVE_ST_SI_MSTATE
         v_state,
#endif
         v_entity
      );
   }

   return v_last_status;
}
#endif

/*
 * call-seq:
 *    Process.pause(signals=nil)
 *
 * Pauses the current process. If the process receives any of the +signals+
 * you pass as arguments it will return from the pause and continue with
 * the execution of your code. Otherwise, it will exit.
 *
 * The +signals+ argument can be an array of integers or strings (or a mix
 * of each) which correspond to signals on your system. If a string is used,
 * be sure to leave off the leading 'SIG' substring, e.g. use 'INT' instead
 * of 'SIGINT'.
 *
 * Note that not all platforms (notably Linux) do not support automatically
 * converting strings to their corresponding signal values, so it is
 * recommended that you always use an array of numeric values.
 *
 * Returns the result of the pause() function, which should always be -1.
 */
static VALUE proc_pause(int argc, VALUE* argv, VALUE mod){
   VALUE v_signals;
   int i;
   long len;

   rb_scan_args(argc, argv, "0*", &v_signals);

   // Iterate over each signal, calling sigset for each one
   len = RARRAY_LEN(v_signals);

   if(len > 0){
      VALUE v_val;
      char signame[SIG2STR_MAX];
      unsigned int max = SIG2STR_MAX;
      int signum;

      for(i = 0; i < len; i++){
         v_val = rb_ary_shift(v_signals);

         if(TYPE(v_val) == T_STRING){
#ifdef HAVE_STRLCPY
            if(strlcpy(signame, StringValuePtr(v_val), max) >= max)
               rb_raise(rb_eArgError, "string too large");
#else
            if(RSTRING(v_val)->len > max)
               rb_raise(rb_eArgError, "string too large");
            else
               strncpy(signame, RSTRING(v_val)->ptr, max);
#endif

#ifdef HAVE_STR2SIG
            if(str2sig(signame, &signum) != 0)
               rb_sys_fail("pause");
#else
            rb_raise(rb_eArgError,
               "platform does not support signal names - use numbers instead"
            );
#endif
         }
         else{
            signum = NUM2INT(v_val);
         }

         sigset(signum, sigproc);
      }
   }

   return INT2FIX(pause()); /* Should always be -1 */
}

/*
 * This is just a placeholder proc to prevent the "pause" method from exiting
 * the program if the appropriate signal is intercepted.
 */
static void sigproc(int signum){ /* Do nothing */ }

#ifdef HAVE_SIGSEND
/*
 * call-seq:
 *    Process.sigsend(idtype, id, signal=0)
 *
 * Sends a signal of type +idtype+ to a process or process group.  This is
 * more versatile method of sending signals to processes than Process.kill.
 *
 * The idtype * must be one of the following values:
 *
 * * Process::P_ALL
 *      All non-system processes. The +id+ is ignored.
 *
 * * Process::P_CID
 *      Any process whose scheduler class ID is equal to +id+.
 *
 * * Process::P_GID
 *      Any non-system process whose effective group ID is equal to +id+.
 *
 * * Process::P_PGID
 *      Any non-system process whose process group ID is equal to +id+.
 *
 * * Process::P_PID
 *      The process ID equal to +id+.
 *
 * * Process::P_PROJID
 *      All processes whose project ID id equal to +id+.  Solaris 8 or later
 *      only.
 *
 * * Process::P_SID
 *      Any non-system process whose session ID is equal to +id+.
 *
 * * Process::P_TASKID
 *      All processes whose task ID is equal to +id+.  Solaris 8 or later
 *      only.
 *
 * * Process::P_UID
 *      Any non-system process whose effective user ID is equal to +id+.
 */
static VALUE proc_sigsend(int argc, VALUE* argv, VALUE mod){
  VALUE v_type, v_pid, v_signal;
  idtype_t idtype;
  id_t id;
  int sig = 0; /* 0 is our default signal (i.e. no signal) */

  rb_scan_args(argc, argv, "21", &v_type, &v_pid, &v_signal);

  idtype = NUM2INT(v_type);
  id = NUM2INT(v_pid);

  if(!NIL_P(v_signal)){
    if(TYPE(v_signal) == T_FIXNUM){
      sig = FIX2INT(v_signal);
    }
    else{
      char signame[SIG2STR_MAX];
      unsigned int max = SIG2STR_MAX;

      if(strlcpy(signame, StringValuePtr(v_signal), max) >= max)
        rb_raise(rb_eArgError, "string too large");

      if(str2sig(signame,&sig) != 0)
        rb_sys_fail("str2sig");
    }
  }

  if(sigsend(idtype,id,sig) != 0)
    rb_sys_fail("sigsend");

  return Qnil;
}
#endif

#ifdef HAVE_GETRUSAGE
/*
 * call-seq:
 *    Process.getrusage(children=false)
 *
 * Returns comprehensive process resource usage information in the form of a
 * RUsage struct. By default, this will return information for the current
 * process. If +children+ is set to true, it will return information for
 * terminated and waited for children of the current process.
 *
 * On Linux platforms the +children+ argument can be set to RUSAGE_THREAD to
 * retrieve thread information instead.
 *
 * The RUsage struct contains the following members:
 *
 * * utime     - User time
 * * stime     - System time
 * * maxrss    - Maximum resident set size
 * * intrss    - Integral shared memory size
 * * idrss     - Integral unshared data size
 * * isrss     - Integral unshared statck size
 * * minflt    - Minor page faults
 * * majflt    - Major page faults
 * * nswap     - Number of swaps
 * * inblock   - Block input operations
 * * oublock   - Block output operations
 * * msgsnd    - Messages sent
 * * msgrcv    - Messages received
 * * nsignals  - Number of signals received
 * * nvcsw     - Voluntary context switches
 * * nivcsw    - Involuntary context switches
 *
 * Note that not all members contain meaningful values on all platforms.
 */
static VALUE proc_getrusage(int argc, VALUE* argv, VALUE mod){
  VALUE v_children = Qfalse;
  struct rusage r;
  int who = RUSAGE_SELF;

  rb_scan_args(argc, argv, "01", &v_children);

  if(TYPE(v_children) == T_FIXNUM)
    who = FIX2INT(v_children);
  else if(RTEST(v_children))
    who = RUSAGE_CHILDREN;

  if(getrusage(who,&r) == -1)
    rb_sys_fail("getrusage");

  return rb_struct_new(v_usage_struct,
    rb_float_new((double)r.ru_utime.tv_sec+(double)r.ru_utime.tv_usec/1e6),
    rb_float_new((double)r.ru_stime.tv_sec+(double)r.ru_stime.tv_usec/1e6),
    LONG2NUM(r.ru_maxrss),
    LONG2NUM(r.ru_ixrss),
    LONG2NUM(r.ru_idrss),
    LONG2NUM(r.ru_isrss),
    LONG2NUM(r.ru_minflt),
    LONG2NUM(r.ru_majflt),
    LONG2NUM(r.ru_nswap),
    LONG2NUM(r.ru_inblock),
    LONG2NUM(r.ru_oublock),
    LONG2NUM(r.ru_msgsnd),
    LONG2NUM(r.ru_msgrcv),
    LONG2NUM(r.ru_nsignals),
    LONG2NUM(r.ru_nvcsw),
    LONG2NUM(r.ru_nivcsw)
  );
}
#endif

#ifdef HAVE_GETDTABLESIZE
/*
 * call-seq:
 *    Process.getdtablesize
 *
 * Returns the current soft limit of the maximum file descriptor number.  This
 * is effectively the same as calling Process.getrlimit with RLIMIT_NOFILE
 * as the resource identifier.
*/
static VALUE proc_getdtablesize(VALUE mod){
  return INT2FIX(getdtablesize());
}
#endif

/*
 * Adds the wait3, wait4, waitid, pause, sigsend, and getrusage methods to the
 * Process module.
 */
void Init_wait3()
{
  v_procstat_struct =
    rb_struct_define("ProcStat","pid","status","utime","stime","maxrss",
      "ixrss", "idrss", "isrss", "minflt","majflt","nswap","inblock",
      "oublock","msgsnd", "msgrcv","nsignals","nvcsw","nivcsw","stopped",
       "signaled","exited","success","coredump","exitstatus","termsig",
       "stopsig",NULL
    );

  rb_define_module_function(rb_mProcess, "wait3", proc_wait3, -1);
  rb_define_module_function(rb_mProcess, "pause", proc_pause, -1);

#ifdef HAVE_GETDTABLESIZE
  rb_define_module_function(rb_mProcess,"getdtablesize",proc_getdtablesize,0);
#endif

#ifdef HAVE_SIGSEND
  rb_define_module_function(rb_mProcess, "sigsend", proc_sigsend, -1);
#endif

#ifdef HAVE_WAIT4
  rb_define_module_function(rb_mProcess, "wait4", proc_wait4, -1);
#endif

#ifdef HAVE_GETRUSAGE
  v_usage_struct =
    rb_struct_define("RUsage","utime","stime","maxrss","ixrss","idrss",
      "isrss","minflt","majflt","nswap","inblock","oublock","msgsnd",
      "msgrcv","nsignals","nvcsw","nivcsw",NULL
    );

  rb_define_module_function(rb_mProcess, "getrusage", proc_getrusage, -1);
#endif

#ifdef HAVE_WAITID
  v_siginfo_struct =
    rb_struct_define("SigInfo", "signo", "errno", "code", "pid", "uid"
#ifdef HAVE_ST_SI_UTIME
      ,"utime"
#endif
#ifdef HAVE_ST_SI_STATUS
      ,"status"
#endif
#ifdef HAVE_ST_SI_STIME
      ,"stime"
#endif
#ifdef HAVE_ST_SI_TRAPNO
      ,"trapno"
#endif
#ifdef HAVE_ST_SI_PC
      ,"pc"
#endif
#ifdef HAVE_ST_SI_FD
      ,"fd"
#endif
      ,"band"
#ifdef HAVE_ST_SI_FADDR
      ,"faddr"
#endif
#ifdef HAVE_ST_SI_TSTAMP
      ,"tstamp"
#endif
#ifdef HAVE_ST_SI_SYSCALL
      ,"syscall"
#endif
#ifdef HAVE_ST_SI_NSYSARG
      ,"nsysarg"
#endif
#ifdef HAVE_ST_SI_FAULT
      ,"fault"
#endif
#ifdef HAVE_ST_SI_SYSARG
      ,"sysarg"
#endif
#ifdef HAVE_ST_SI_MSTATE
      ,"mstate"
#endif
      ,"entity", NULL
    );

  rb_define_module_function(rb_mProcess, "waitid", proc_waitid, -1);

#ifdef WCONTINUED
  /* The status of any child that was stopped and then continued */
  rb_define_const(rb_mProcess, "WCONTINUED", INT2FIX(WCONTINUED));
#endif

#ifdef WEXITED
  /* The status of any child that has terminated */
  rb_define_const(rb_mProcess, "WEXITED", INT2FIX(WEXITED));
#endif

#ifdef WNOWAIT
  /* Keeps the process whose status was returned in a waitable state */
  rb_define_const(rb_mProcess, "WNOWAIT", INT2FIX(WNOWAIT));
#endif

#ifdef WSTOPPED
  /* The status of any child that has stopped as the result of a signal */
  rb_define_const(rb_mProcess, "WSTOPPED", INT2FIX(WSTOPPED));
#endif

#ifdef WTRAPPED
  /* Waits for any child process to become trapped or reach a breakpoint */
  rb_define_const(rb_mProcess, "WTRAPPED", INT2FIX(WTRAPPED));
#endif
#endif

  /* Because core Ruby already defines a Process::GID and Process::UID,
   * I am forced to keep the leading 'P_' for these constants.
   */

#ifdef HAVE_CONST_P_ALL
  /* Any child */
  rb_define_const(rb_mProcess, "P_ALL", INT2FIX(P_ALL));
#endif

#ifdef HAVE_CONST_P_PGID
  /* Process group ID */
  rb_define_const(rb_mProcess, "P_PGID", INT2FIX(P_PGID));
#endif

#ifdef HAVE_CONST_P_PID
  /* Process ID */
  rb_define_const(rb_mProcess, "P_PID", INT2FIX(P_PID));
#endif

#ifdef HAVE_CONST_P_CID
  /* Process scheduler class ID */
  rb_define_const(rb_mProcess, "P_CID", INT2FIX(P_CID));
#endif

#ifdef HAVE_CONST_P_GID
  /* Non-system process effective group ID */
  rb_define_const(rb_mProcess, "P_GID", INT2FIX(P_GID));
#endif

#ifdef HAVE_CONST_P_MYID
  /* Process ID of the calling process */
  rb_define_const(rb_mProcess, "P_MYID", INT2FIX(P_MYID));
#endif

#ifdef HAVE_CONST_P_SID
  /* Non-system process session ID */
  rb_define_const(rb_mProcess, "P_SID", INT2FIX(P_SID));
#endif

#ifdef HAVE_CONST_P_UID
  /* Non-system process effective user ID */
  rb_define_const(rb_mProcess, "P_UID", INT2FIX(P_UID));
#endif

#ifdef HAVE_CONST_P_TASKID
  /* Process task ID */
  rb_define_const(rb_mProcess, "P_TASKID", INT2FIX(P_TASKID));
#endif

#ifdef HAVE_CONST_P_PROJID
  /* Process project ID */
  rb_define_const(rb_mProcess, "P_PROJID", INT2FIX(P_PROJID));
#endif

#ifdef HAVE_CONST_RUSAGE_THREAD
  rb_define_const(rb_mProcess, "RUSAGE_THREAD", INT2FIX(RUSAGE_THREAD));
#endif

  /* 1.7.2: The version of the proc-wait3 library */
  rb_define_const(rb_mProcess, "WAIT3_VERSION", rb_str_new2("1.7.3"));

  /* Define this last in our Init_wait3 function */
  rb_define_readonly_variable("$last_status", &v_last_status);
}
