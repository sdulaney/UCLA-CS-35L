#!/usr/bin/env python3

"""
shuf - generate random permutations/shuffle lines of text
"""

import random, sys
from optparse import OptionParser

class shufline:
    def __init__(self, filename=None, input_lines=None):
        if filename is not None:
            f = open(filename, 'r')
            self.lines = f.read().splitlines()
            f.close()
        elif input_lines is not None:
            self.lines = input_lines[:]

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
    version_msg = "%prog 1.0"
    usage_msg = """
%prog [OPTION]... [FILE]
%prog -i LO-HI [OPTION]...

Generate random permutations/shuffle lines of text."""
    
    parser = OptionParser(version=version_msg,
                          usage=usage_msg)
    parser.add_option("-i", "--input-range",
                      action="store", dest="input_range", default=None,
                      help="Act as if input came from a file containing the range of unsigned dec\
imal integers LO...HI, one per line.\n")
    parser.add_option("-n", "--head-count",
                      action="store", dest="head_count", default=None,
                      help="Output at most COUNT lines. By default, all input lines are output.\n")
    parser.add_option("-r", "--repeat",
                      action="store_true", dest="repeat", default=False,
                      help="Repeat output values, that is, select with replacement. With this option the output is not a permutation of the input; instead, each output line is randomly chosen from all the inputs. This option is typically combined with --head-count; if --head-count is not given, shuf.py repeats indefinitely.\n")
    options, args = parser.parse_args(sys.argv[1:])

    input_lines = None
    input_file = None
    numlines = None

    # option --input-range (-i)
    if options.input_range is not None:
        if len(args) != 0:
            parser.error("extra operand \'{0}\'".format(args[0]))
        lo_hi = options.input_range.split("-", 1)
        if len(lo_hi) == 1:
            parser.error("invalid input range: \'{0}\'".format(lo_hi[0]))
        try:
            lo = int(lo_hi[0])
        except:
            parser.error("invalid input range: \'{0}\'".format(lo_hi[0]))
        try:
            hi = int(lo_hi[1])
        except:
            parser.error("invalid input range: \'{0}\'".format(lo_hi[1]))
        if lo > hi + 1:
            parser.error("invalid input range: \'{0}\'".format(options.input_range))
        
        input_lines = list(range(lo, hi + 1))
    else:
        if len(args) > 1:
            parser.error("wrong number of operands")
        elif len(args) == 0:
            try:
                input_lines = sys.stdin.read().splitlines()
            except IOError as err:
                errno, strerror = err.args
                parser.error("I/O error({0}): {1}".
                         format(errno, strerror))
        elif len(args) == 1:
            if args[0] == "-":
                try:
                    input_lines = sys.stdin.read().splitlines()
                except IOError as err:
                    errno, strerror = err.args
                    parser.error("I/O error({0}): {1}".
                         format(errno, strerror))
            else:
                if options.head_count is not None:
                    try:
                        numlines = int(options.head_count)
                    except:
                        parser.error("invalid line count: \'{0}\'".
                                     format(options.head_count))
                    if numlines == 0:
                        exit(0)
                input_file = args[0]
                try:
                    temp_f = open(input_file, 'r')
                    temp_f.close()
                except:
                    parser.error("Can not open file {0}.".format(input_file))

    # option --head-count (-n)
    if options.head_count is not None:
        try:
            numlines = int(options.head_count)
        except:
            parser.error("invalid line count: \'{0}\'".
                     format(options.head_count))
        if numlines < 0:
            parser.error("invalid line count: \'{0}\'".
                     format(options.head_count))

    generator = shufline(filename=input_file, input_lines=input_lines)

    # option --repeat (-r)
    if options.repeat == True:
        if len(generator.lines) == 0:
            parser.error("no lines to repeat")
        if numlines == None:
            while True:
                sys.stdout.write(str(generator.get_lines(head_lines=numlines, repeat=options.repeat)) + "\n")
    
    try:
        output = generator.get_lines(head_lines=numlines, repeat=options.repeat)
        for line in output:
            sys.stdout.write(str(line) + "\n")
    except IOError as err:
        errno, strerror = err.args
        parser.error("I/O error({0}): {1}".
                     format(errno, strerror))

if __name__ == "__main__":
    main()
