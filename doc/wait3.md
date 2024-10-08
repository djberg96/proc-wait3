## Description
Adds the `wait3`, `wait4`, `waitid`, `pause`, `sigsend`, and `getrusage`
methods to the Process module.

## Synopsis
```ruby
require 'proc/wait3'

pid = fork{ sleep 1; exit 2 }
p Time.now
Process.wait3
p $?
```

## Module Methods
### `Process.pause(signals=nil)`

Pauses the current process. If the process receives any of the signals
you pass as arguments it will return from the pause and continue with
the execution of your code. Otherwise, it will exit.
 
Note that you must leave out the 'SIG' prefix for the signal name, e.g.
use 'INT', not 'SIGINT'.

Returns the result of the underlying `pause()` function, which should always be -1.
   
### `Process.sigsend(idtype, id, signal=0)`

Sends a signal of type "idtype" to a process or process group "id". This
is more versatile method of sending signals to processes than Process.kill.
   
For a list of valid idtype values, see the "Process type constants" below.
Not supported on all platforms.
   
### `Proc.wait3(flags=0)`

Delays its caller until a signal is received or one of its child processes
terminates or stops due to tracing.

The return value is a ProcStat structure and sets the `$last_status` global
variable. The special global $? is also set. Raises a SystemError if there
are no child processes.

### `Proc.wait4(pid, flags=0)`

Waits for the given child process to exit. Returns a ProcStat structure.
The `$last_status` global variable is set. Also sets the `$?` special global
variable.
   
### `Proc.waitid(id_type, id_num=nil, options=nil)`

Suspends the calling process until one of its children changes state,
returning immediately if a child process changed state prior to the call.
The state of a child process will change if it terminates, stops because
of a signal, becomes trapped or reaches a breakpoint.

The `id_num` corresponds to a process ID or process group ID, depending on
the value of `id_type`, which may be `Process::P_PID`, `Process::P_PGID` or
`Process::P_ALL`. If `id_type` is `Process::P_ALL`, then the `id_num` is ignored.

The options argument is used to specify which state changes are to be
waited for. It is constructed from the bitwise-OR of one or more of the
following constants:

* Process::WCONTINUED
* Process::WEXITED
* Process::WNOHANG
* Process::WNOWAIT
* Process::WSTOPPED
* Process::WTRAPPED (not supported on all platforms)

If `Process::WNOHANG` is set as an option, this method will return
immediately, whether or not a child has changed state.

Calling this method with an `id_type` of `Process::P_ALL` and the options set
to `Process::EXITED | Process::WTRAPPED` is equivalent to calling
Process.wait.

Returns a `Proc::SigInfo` struct and sets `$?`.

Not supported on all platforms.

### `Proc.getdtablesize`

Returns the current soft limit of the maximum file descriptor number.

This is effectively the same as calling Process.getrlimit with RLIMIT_NOFILE
as the resource identifier.

## Standard Constants
`Process::WAIT3_VERSION`

Returns the version of this package as a string.

## Process type constants - all platforms
`Process::P_ALL`

All non-system process.

`Process::P_PID`

A standard process id.

`Process::P_PGID`

Any non-system process group id.

## Process type constants - not all platforms supported
`Process::P_CID`

A scheduler process id.

`Process::P_GID`

Any non-system effective process group id.

`Process::P_PROJID`

A project process id. Solaris 8 or later only.

`Process::P_SID`

A session process id.

`Process::P_TASKID`

A task process id. Solaris 8 or later only.

`Process::P_UID`

Any non-system effective process user id.

## Additional Process constants - defined if waitid is defined on your system
`Process::WCONTINUED`

Return the status for any child that was stopped and has been continued.

`Process::WEXITED`

Wait for process(es) to exit.

`Process::WNOWAIT`

Keep the process in a waitable state.

`Process::WSTOPPED`

Wait for and return the process status of any child that has stopped upon
receipt of a signal.

`Process::WTRAPPED`

Wait for traced process(es) to become trapped or reach a breakpoint.

Not supported on all platforms.
   
## RLIMIT constants
`Process::RLIMIT_AS`

A synonym for `RLIMIT_VMEM`.
   
`Process::RLIMIT_CORE`

The maximum size of a core file, in bytes, that may be created.
   
`Process::RLIMIT_CPU`

The maximum amount of CPU time, in seconds, the process is allowed to use.
   
`Process::RLIMIT_DATA`

The maximum size of the process' heap size, in bytes.
   
`Process::RLIMIT_FSIZE`

The maximum size of a file, in bytes, that the process may create.
   
`Process::RLIMIT_NOFILE`

The maximum value that the kernel may assign to a file descriptor,
effectively limiting the number of open files for the calling process.
   
`Process::RLIMIT_STACK`

The maximum size of the process' stack in bytes.
   
`Process::RLIMIT_VMEM`

The maximum size of the process' mapped address space.
   
`Process::RLIM_INFINITY`

A infinite limit.
   
`Process::RLIM_SAVED_CUR`

Current soft limit.
   
`Process::RLIM_SAVED_MAX`

Current hard limit.

## Notes
The `wait3` and `wait4` methods are similar to the `wait2` and `waitpid2`
methods, except that they return much more information via the rusage
struct.

## Future Plans
Wrap the wait6 function, and add better BSD support in general.

## Known Bugs
None that I'm aware of. Please log any bugs on the Github project
page at https://github.com/djberg96/proc-wait3.

## License
Apache-2.0

## Copyright
(C) 2003-2024 Daniel J. Berger

All Rights Reserved.

## Warranty
This package is provided "as is" and without any express or
implied warranties, including, without limitation, the implied
warranties of merchantability and fitness for a particular purpose.

## Author
Daniel J. Berger

## See also
wait3, wait4, waitid, pause, sigsend
