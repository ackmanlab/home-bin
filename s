#! /usr/bin/python
# adapted from https://stackoverflow.com/questions/59052703/grep-or-ripgrep-how-to-find-only-files-that-match-multiple-patterns-not-only-o

import sys
import subprocess
from itertools import permutations

usage = """
Search with multiple keywords across files within current and subdirs using ripgrep. Provides boolean AND type search.

Usage: s keyword1 keyword2
e.g. s cerebral cetacean sand | f 
"""
 
# Check that the user puts in an argument, else print the usage variable, then quit.
if len(sys.argv)< 2:
    print (usage)
    sys.exit(0)

rgarg = '|'.join(('.*'.join(x) for x in permutations(sys.argv[1:])))
cmd = ['rg', '-lUi', '--multiline-dotall', rgarg, '.']
#  print(' '.join(cmd))
proc = subprocess.run(cmd, capture_output=True)
sys.stdout.write(proc.stdout.decode('utf-8'))
