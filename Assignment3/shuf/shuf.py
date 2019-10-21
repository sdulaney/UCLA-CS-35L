#!/usr/bin/env python3

"""
shuf - generate random permutations/shuffle lines of text
"""

import random, sys
from optparse import OptionParser

class shufline:
    def __init__(self, filename):
        f = open(filename, 'r')
        self.lines = f.readlines()
        f.close()

    def get_lines(self, head_lines=None, repeat=False):
        if repeat:
            # Generate random lines
            if head_lines == None:
                return random.choice(self.lines)
            else:
                shuffled_lines = []
                for i in range(head_lines):
                    shuffled_lines.append(random.choice(self.lines))
                return shuffled_lines
        else:
            # Generate permuted lines
            shuffled_lines = self.lines[:]
            random.shuffle(shuffled_lines)
            if head_lines == None:
                return shuffled_lines
            else:
                if head_lines > len(self.lines):
                    return shuffled_lines
                else:
                    return shuffled_lines[0:head_lines]

def main():
#    version_msg = "%prog 2.0"
#    usage_msg = """%prog [OPTION]... FILE
#
#Output randomly selected lines from FILE."""

    generator = shufline("in")
    output = generator.get_lines()
    print("".join(output), end="")
    
#    parser = OptionParser(version=version_msg,
#                          usage=usage_msg)
#    parser.add_option("-n", "--numlines",
#                      action="store", dest="numlines", default=1,
#                      help="output NUMLINES lines (default 1)")
#    options, args = parser.parse_args(sys.argv[1:])

#    try:
#        numlines = int(options.numlines)
#    except:
#        parser.error("invalid NUMLINES: {0}".
#                     format(options.numlines))
#    if numlines < 0:
#        parser.error("negative count: {0}".
#                     format(numlines))
#    if len(args) != 1:
#        parser.error("wrong number of operands")
#    input_file = args[0]

#    try:
#        generator = randline(input_file)
#        for index in range(numlines):
#            sys.stdout.write(generator.chooseline())
#    except IOError as err:
#        errno, strerror = err.args
#        parser.error("I/O error({0}): {1}".
#                     format(errno, strerror))

if __name__ == "__main__":
    main()
