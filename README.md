Description
===========

init-apt-repos.sh does all of the heavy lifting. It

* creates the directory hierarchy at $HOME/.multideb,
* creates a subdirectory for all releases from lucid to quantal,
* creates amd64 and i386 subdirs,
* creates the necessary configuration and timestamp files,
* downloads package files for main, multiverse, restricted, and universe, and
* runs apt-get update for each of the fake repos.

You may now run apt commands which obey the APT\_CONFIG environment variable.

Links & References
==================

* Idea blatantly stolen from http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=550961#30
