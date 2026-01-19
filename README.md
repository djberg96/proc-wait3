[![Ruby](https://github.com/djberg96/proc-wait3/actions/workflows/ruby.yml/badge.svg)](https://github.com/djberg96/proc-wait3/actions/workflows/ruby.yml)

## Description
Adds the wait3, wait4, waitid, pause, sigsend, and getrusage methods to the Process module.

## Installation
`gem install proc-wait3`

## Synopsis
```ruby
require 'proc/wait3'

pid = fork{
  sleep 1
  exit 2
}

puts Time.now.to_s
Process.wait3
puts $?.exitstatus # => 2
```

## Tested Platforms
* Solaris
* Linux
* FreeBSD
* OS X

## Warnings
Linux users who compile with gcc -Wall will notice a few warnings. These
are harmless (and unavoidable atm).

Linux users may also notice warnings about implicit declarations. These
are also harmless, and can be silenced by installing the libbsd-dev package
first.

These methods may fail in conjunction with `fork` with `Errno::EINTR` unless
you pass the WNOHANG flag, or explicitly ignore the `SIGCHLD` signal. Ruby's
own `wait` methods appear to essentially be doing that behind the scenes.

Note that on some platforms just setting a `SIGCHLD` handler may not be
enough to prevent an `Errno::EINTR` from occuring since you can never be sure
what signal it's going to receive. Since this appears to be coming from the
guts of the Ruby core code itself IMO, it's somewhat out of my hands, but it's
not impossible to deal with.

A typical idiom would be to simulate the `TEMP_FAILURE_RETRY` macro that the GNU
library provides. This macro wraps a given function and retries it so long as
it doesn't fail, or the only failure is an `EINTR`. I've chosen not to integrate
this into the code directly (yet), but you can simulate it like so:

```ruby
require 'English'

begin
  pid = fork{ sleep 1; exit 2 }
  Process.wait3
rescue Errno::EINTR
  retry
end

p $CHILD_STATUS
```

For more information please see:

https://www.gnu.org/savannah-checkouts/gnu/libc/manual/html_node/Interrupted-Primitives.html

BSD provides another approach using sigaction handlers + `SA_RESTART`, but it requires knowing
the signal type in advance. So, unless you want to apply the same handler to *every* type of
signal, I don't find it especially useful.

Update: As of version 2.1.0 you should no longer have to manually rescue EINTR since it's now
being handled internally.

## Integration with Ruby's process.c
I considered simply providing a patch to the core process.c file, but I
decided against it for two reasons.  First, I wanted to get something
out more quickly rather than waiting for approval from the core developers
who, based on an earlier post, seem somewhat gun-shy about integrating support
for wait3() and wait4() based, I think, on portability concerns.

Second, and more importantly, I don't like the cProcStatus class.  The
extra inspection code seems like an awful lot of work for very little gain.
The overloaded methods are also overkill, and do nothing but save me the
trouble of typing the word "status", since all they're for is comparing or
operating on the status attribute.

## Additional Documentation
Please see the doc/wait3.md file for detailed documentation.
