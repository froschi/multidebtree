#!/usr/bin/env python

import apt
import pprint
import sys

# Debugging
pp = pprint.PrettyPrinter()

endlist = []   # endlist from debtree config
skiplist = []  # skiplist from debtree config
deplist = []   # list of dependencies of a particular package.

endfile = "/home/thorsten/.debtree/endlist"
skipfile = "/home/thorsten/.debtree/skiplist"

def list_diff(list1, list2):
  return list(set(list1) - set(list2))

endlist = [line.strip() for line in open(endfile)]
skiplist = [line.strip() for line in open(skipfile)]

pkg_name = sys.argv[1]

cache = apt.Cache()
pkg = cache[pkg_name]

deps = pkg.versions[0].dependencies
deplist = [dep[0].name for dep in deps]
deplist = list_diff(deplist, skiplist)

print ("%s:%s") % (pkg_name, ','.join(deplist))
