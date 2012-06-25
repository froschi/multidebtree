#!/usr/bin/env python

from collections import deque
import apt
import os
import pprint
import sys

# Debugging
pp = pprint.PrettyPrinter()

endlist = []   # endlist from debtree config
skiplist = []  # skiplist from debtree config
deplist = []   # list of dependencies of a particular package.
extlist = []  # list of existing cookbooks
donelist = [] # list of things already processed this session.
workdeque = deque()

package_mappings = ['libgcrypt11']

endfile = "/home/thorsten/.debtree/endlist"
skipfile = "/home/thorsten/.debtree/skiplist"
endlist = [line.strip() for line in open(endfile)]
skiplist = [line.strip() for line in open(skipfile)]

cookbook_path = "/home/thorsten/scm/code/chef/cookbooks/"
extlist = [dname for dname in os.listdir(cookbook_path)]

def list_diff(list1, list2):
  return list(set(list1) - set(list2))

def process_package(pkg_name):
  pkg = cache[pkg_name]
  if pkg in donelist:
    return
  donelist.append(pkg) 
  deps = pkg.versions[0].dependencies
  deplist = [dep[0].name for dep in deps]
  deplist = list_diff(deplist, skiplist)
  if pkg_name in package_mappings:
      print "\033[92m%s\033[0m(+):" % pkg_name,
  else:
      print "\033[91m%s\033[0m:" % pkg_name,
  for d in deplist:
    if d in package_mappings:
      print "\033[92m%s\033[0m(-)" % d,
    else:
      print "\033[91m%s\033[0m" % d,
  print
  more_list = list_diff(deplist, endlist)
  more_list = list_diff(more_list, donelist)
  more_list = list_diff(more_list, extlist)
  for m in more_list:
    workdeque.append(m)

cache = apt.Cache()
pkg_name = sys.argv[1]

workdeque.append(pkg_name)

while True:
  try:
    process_package(workdeque.pop())
  except:
    break
