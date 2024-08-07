## 1.9.3 - 4-May-2024
* Some internal refactoring where I bzero C structs before using them.

## 1.9.2 - 21-Apr-2024
* Added the P_JAILID constant for BSD platforms.
* Added some notes to the README for coping with EINTR.
* Added rubocop and rubocop-rspec as dev dependencies and did
  some general rubocop cleanup.

## 1.9.1 - 8-Feb-2024
* Replace sigset with sigaction in the pause method.
* General cleanup and platform handling updates.

## 1.9.0 - 7-Jan-2021
* Switched from test-unit to rspec.
* Skip some tests on Darwin because of EINTR errors.
* Switched from rdoc to markdown since github isn't rendering rdoc properly.
* Added a Gemfile.

## 1.8.1 - 8-Apr-2020
* Added a LICENSE file to the distribution as required by the Apache-2.0 license.
* Add an explicit .rdoc extension to the README, CHANGES and MANIFEST files.

## 1.8.0 - 20-Feb-2019
* Changed license to Apache-2.0.
* Now requires Ruby 2.2 or later.
* Now checks for <bsd/string.h> header and include's it if found. This was
  mainly to help silence some implicit declaration warnings on Linux.
* The WAIT3_VERSION constant is now frozen.
* Updated the cert, should be good for about 10 years.
* Added metadata to the gemspec.
* Removed some old macro checks/definitions that were no longer relevant.
* Added a proc-wait3.rb file for convenience.

## 1.7.3 - 21-Nov-2015
* Fixed a bug where tv_usec was divided by 1k instead of 1e6. Thanks go to
  Jason Gladish for the spot.
* This gem is now signed.
* The gem related tasks in the Rakefile now assume Rubygems 2.x.

## 1.7.2 - 5-Sep-2014
* Added support for the RUSAGE_THREAD constant on Linux. Thanks go to
  Bruno Michel for the patch.

## 1.7.1 - 24-Apr-2014
* Explicitly check for and include sys/resource.h because Debian. Thanks
  go to Christos Trochalakis for the spot.

## 1.7.0 - 6-Apr-2014
* The wait3 and wait4 methods no longer set $? to a custom struct. The builtin
  variable is still set, but if you need the custom Struct::ProcStat information
  then use the $last_status global instead, or just use the return value. This
  was changed thanks to an issue pointed out by Michael Lee Squires where
  subsequent system calls no longer set $? properly.
* Some build warning fixes for BSD platforms.
* Some test updates for BSD and Solaris.

## 1.6.0 - 28-Aug-2011
* Removed the getrlimit and setrlimit methods. Ruby has supported these methods
  since Ruby 1.8.5, so I think it's time to finally dump them.
* Fixed two build warnings regarding unused variables and one 32/64 cast warning.

## 1.5.6 - 7-Jan-2010
* Checks are now made for the si_fd, si_utime, si_status and si_stime siginfo_t
  struct members. This addresses build failures on OS X 10.5 and later where
  those struct members went mysteriously MIA.
* The have_const method is no longer added to your mkmf.rb file. It is simply
  defined in the extconf.rb file.
* Some gemspec and Rakefile refactoring.
* Updates to the README.
* Source code moved to github.

## 1.5.5 - 8-Aug-2009
* Now compatible with Ruby 1.9.x.
* License changed to Artistic 2.0.
* Added test-unit 2.x as a development dependency.
* Test suite refactored to take advantage of some of the features of
  test-unit 2.x, as well as fixes (skips) for BSD platforms.
* Several gemspec updates, including the license and description.
* Renamed test file to test_proc_wait3.rb.
* Example files renamed to avoid any confusion with actual test files.
* Several Rake tasks added to run individual example programs.

## 1.5.4 - 7-Feb-2008
* ALERT! ALERT! Now auto-patches your mkmf.rb file to add the 'have_const'
  method if it's not already found. This is necessary to determine if certain
  enum values exist on your system. Your original mkmf.rb is backed up first
  in case you ever need to restore it.
* Added lots of rdoc comments for the various constant values.
* Internal directory structure changes.
* Minor tweaks to the Rakefile and gem spec.
* Fixed the extconf.rb file so that it sets the target directory properly.
* No source code changes (except for comment updates and a version bump).

## 1.5.3 - 25-Oct-2006
* Because not all platforms support automatically converting signal names
  into their equivalent numbers, the Process.pause method now accepts names
  or numbers.  It will raise an ArgumentError if you try to use a signal name
  on a platform that doesn't support the str2sig() function (such as Linux).
* Fixed a bug where fractional seconds for utime/stime were not reported in
  the Process.getrusage method.  Thanks go to Eric Hodel for the spot and
  the patch.
* Fixed potential bigint overflow issues in the Process.getrusage method.
  Thanks go again to Eric Hodel.
* Internal fixes for platforms that don't support the strlcpy() function.
* Minor update for the test_pause.rb example program.

## 1.5.2 - 24-Jul-2006
* Fixed the way I was handling whether or not Ruby already defined the various
  RLIMIT constants within wait3.c.
* Fixed the way in which certain RLIM constants were being converted. I
  shamelessly plagiarized from process.c for this.
* Adds the RLIMIT_MEMLOCK constant if found and not already defined.
* Added the WAIT3_VERSION constant.
* The getrlimit and setrlimit tests are now skipped for Ruby 1.8.5 or later.

## 1.5.1 - 13-Jul-2006
* Fixed bugs with improper values being set for some of the rlimit constants.
* Cleaned up a few warnings related to signed-ness for the RLIM_xxx constants.
* Now only sets the various rlimit constants if they're not already defined
  (which Ruby now defines, as of 1.8.5).
* Some internal cleanup.
* Created a gemspec and added a gem to RubyForge.

## 1.5.0 - 12-Jun-2006
* Removed the '?' character from the various struct members, since Ruby
  no longer (properly) handles them.
* Fixed a 64 bit bug related to rb_struct_define.
* Added some more tests.

## 1.4.3 - 28-Jun-2005
* Added more #ifdef checks for some of the process flags which, it turns
  out, are not defined in earlier versions of Linux.

## 1.4.2 - 14-Jun-2005
* Fixed a syntax error that could cause the build to fail.
* Removed some (but not all) possible warnings from gcc -Wall.

## 1.4.1 - 13-Jun-2005
* Added support for the Linux 2.6.9+ kernel (by adding more preprocessor
  constant checks, which may help with other platforms as well).
* Moved project to RubyForge.
* Modified test suite - some tests now skipped on Linux.
* Removed the wait3.rd file.
* Minor fix for the test_waitid.rb sample program.

## 1.4.0 - 16-Feb-2005
* Added the getrusage method.
* Added test cases and documentation for getrusage.
* Renamed a couple test files in the examples directory.

## 1.3.0 - 14-Feb-2005
* Added the pause and sigsend methods.
* I had to modify the process type constants to include the "P_", because
  Ruby already has Process::GID and Process::UID defined.  That makes this
  release incompatible with previous versions.
* Updated tests and documentation.

## 1.2.0 - 7-Feb-2005
* Added the Proc.waitid method (for those platforms that support it). 
* Made the wait3.c file more rdoc friendly.
* Added a test_waitid.rb file in the examples directory.

## 1.1.1 - 10-Jan-2005
* Eliminated some (harmless) warnings that cropped up in 1.8.2
* Moved the "examples" directory to the toplevel directory.
* Made docs slightly more rdoc friendly

## 1.1.0 - 14-Sep-2004
* Modified setup and source to handle the possibility that wait3() might
  be defined while wait4() is not (e.g. HPUX).
* Modified the test scripts in the examples directory to play nice on HPUX
  and Darwin.
* Added this file (oops).

## 1.0.0 - 13-Sep-2004
- Initial release
