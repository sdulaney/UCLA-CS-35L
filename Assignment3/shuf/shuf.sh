#!/bin/sh
# Test that shuf.py meets the spec for Assignment 3.
# Assumes the exit status 2 returned by OptionParser.error() is the only code indicating failure for shuf.py.

seq 100 > in

# Your program should support a single non-option argument other than "-" (which specifies the input file name).
python3 shuf.py in >out || fail=1

# Fail if the input is the same as the output.
# This is a probabilistic test :-)
# However, the odds of failure are very low: 1 in 100! (~ 1 in 10^158)
cmp in out > /dev/null && { fail=1; echo "not random?" 1>&2; }

# Fail if the sorted output is not the same as the input.
sort -n out > out1
cmp in out1 || { fail=1; echo "not a permutation" 1>&2; }

# Exercise shuf's -i option.
#python3 shuf.py -i 1-100 > out || fail=1
#compare in out > /dev/null && { fail=1; echo "not random?" 1>&2; }
#sort -n out > out1
#compare in out1 || { fail=1; echo "not a permutation" 1>&2; }

# Exercise shuf's --input-range option.
#python3 shuf.py --input-range=1-100 > out || fail=1
#compare in out > /dev/null && { fail=1; echo "not random?" 1>&2; }
#sort -n out > out1
#compare in out1 || { fail=1; echo "not a permutation" 1>&2; }

# Exercise shuf's -n option.
#python3 shuf.py -i 1-100 -n 9 > out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 9 || { fail=1; echo "Option -n failed">&2 ; }

# Exercise shuf's --head-count option.
#python3 shuf.py -i 1-100 --head-count=9 > out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 9 || { fail=1; echo "Option --head-count failed">&2 ; }

# Exercise shuf's -r option.
#python3 shuf.py -i 1-10 -n 100 -r  > out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 100 || { fail=1; echo "Option -r failed">&2 ; }

# Exercise shuf's --repeat option.
#python3 shuf.py -i 1-10 -n 100 --repeat  > out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 100 || { fail=1; echo "Option --repeat failed">&2 ; }

# Exercise shuf's --help option.
#python3 shuf.py --help > out || fail=1
#cmp out shuf--help.txt || { fail=1; echo "Option --help failed">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 0 options
#cat in | python3 shuf.py >out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 100 || { fail=1; echo "Zero non-option arguments and zero option arguments failed">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 1 options
#cat in | python3 shuf.py -i 0-9 >out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 10 || { fail=1; echo "Zero non-option arguments and one option arguments failed (-i should override no FILE and not read from STDIN)">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 2 options
#cat in | python3 shuf.py -r -n 1000 >out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 1000 || { fail=1; echo "Zero non-option arguments and two option arguments failed">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 3 options
#cat in | python3 shuf.py -r -n 1000 -i 0-9 >out || fail=1
#c=$(sort -u < out)
#test "$c" -eq 10 || { fail=1; echo "Zero non-option arguments and three  option arguments failed (-i should override no FILE and not read from STDIN)">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 0 options
#cat in | python3 shuf.py - >out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 100 || { fail=1; echo "Single non-option argument "-" and zero option arguments failed">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 1 options (option -i and FILE equal to - should crash the program)
#cat in | python3 shuf.py - -i 0-9 >out
#test $? -eq 2 || fail=1

# Your program should support a single non-option argument "-" (means read from standard input) - 2 options
#cat in | python3 shuf.py - -r -n 1000 >out || fail=1
#c=$(wc -l < out)
#test "$c" -eq 1000 || { fail=1; echo "Single non-option argument "-" and two option arguments failed">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 3 options (option -i and FILE equal to - should crash the program)
#cat in | python3 shuf.py - -r -n 1000 -i 0-9 >out
#test $? -eq 2 || fail=1

# Invalid arguments
#python3 shuf.py -r /dev/null
#test $? -eq 2 || fail=1

# Invalid arguments: with a single redundant operand with --input-range
#python3 shuf.py -i0-0 1
#test $? -eq 2 || fail=1

# Avoid infloop.
# "seq 1860" produces 8193 (8K + 1) bytes of output.
#seq 1860 | python3 shuf.py > /dev/null || fail=1

# Ensure shuf -n operates efficiently for small n. Before coreutils-8.13
# this would try to allocate $SIZE_MAX * sizeof(size_t)
#timeout 10 python3 shuf.py -i1-$SIZE_MAX -n2 >/dev/null ||
 #   { fail=1; echo "couldn't get a small subset" >&2; }

# Ensure shuf -n0 doesn't read any input or open specified files
#touch unreadable
#chmod 0 unreadable
#if ! test -r unreadable; then
#  python3 shuf.py -n0 unreadable || fail=1
#  { python3 shuf.py -n1 unreadable || test $? -ne 2; } && fail=1
#fi

# Multiple -n is accepted, should use the smallest value
#python3 shuf.py -n10 -i0-9 -n3 -n20 > exp
#c=$(wc -l < exp)
#test "$c" -eq 3 || { fail=1; echo "Multiple -n failed">&2 ; }

# Test error conditions

# Test invalid value for -n
#{ python3 shuf.py -nA || test $? -ne 2; } &&
#  { fail=1; echo "shuf did not detect erroneous -n usage.">&2 ; }
# Test multiple -i
#{ python3 shuf.py -i0-9 -n10 -i8-90 || test $? -ne 2; } &&
#  { fail=1; echo "shuf did not detect multiple -i usage.">&2 ; }
# Test invalid range
#for ARG in '1' 'A' '1-' '1-A'; do
#    { python3 shuf.py -i$ARG || test $? -ne 2; } &&
#    { fail=1; echo "shuf did not detect erroneous -i$ARG usage.">&2 ; }
#done

# Test --repeat option

# --repeat without count should return an indefinite number of lines
# As with GNU shuf, if --repeat (-r) is used without --head-count (-n), your program should run forever.
#python3 shuf.py --rep -i 0-10 | head -n 1000 > exp
#c=$(wc -l < exp)
#test "$c" -eq 1000 \
#  || { fail=1; echo "--repeat does not repeat indefinitely">&2 ; }

# --repeat can output more values than the input range
#python3 shuf.py --rep -i0-9 -n1000 > exp
#c=$(wc -l < exp)
#test "$c" -eq 1000 || { fail=1; echo "--repeat with --count failed">&2 ; }

# Check output values (this is not bullet-proof, but drawing 1000 values
# between 0 and 9 should produce all values, unless there's a bug in shuf
# or a very poor random source, or extremely bad luck)
#c=$(sort -nu exp | paste -s -d ' ')
#test "$c" = "0 1 2 3 4 5 6 7 8 9" ||
#    { fail=1; echo "--repeat produced bad output">&2 ; }

# check --repeat with non-zero low value
#python3 shuf.py --rep -i222-233 -n2000 > exp
#c=$(sort -nu exp | paste -s -d ' ')
#test "$c" = "222 223 224 225 226 227 228 229 230 231 232 233" ||
# { fail=1; echo "--repeat produced bad output with non-zero low">&2 ; }

# --repeat,-i,count=0 should not fail and produce no output
#python3 shuf.py --rep -i0-9 -n0 > exp
# file size should be zero (no output from shuf)
#test \! -s exp ||
#    { fail=1; echo "--repeat,-i0-9,-n0 produced bad output">&2 ; }

# --repeat with STDIN, without count, should repeat indefinitely
#printf "A\nB\nC\nD\nE\n" | python3 shuf.py --rep | head -n 1000 > exp
#c=$(wc -l < exp)
#test "$c" -eq 1000 ||
#  { fail=1; echo "--repeat,STDIN does not repeat indefinitely">&2 ; }

# --repeat with STDIN,count - can return more values than input lines
#printf "A\nB\nC\nD\nE\n" | python3 shuf.py --rep -n2000 > exp
#c=$(wc -l < exp)
#test "$c" -eq 2000 ||
#    { fail=1; echo "--repeat,STDIN,count failed">&2 ; }

# Check output values (this is not bullet-proof, but drawing 2000 values
# between A and E should produce all values, unless there's a bug in shuf
# or a very poor random source, or extremely bad luck)
#c=$(sort -u exp | paste -s -d ' ')
#test "$c" = "A B C D E" ||
#  { fail=1; echo "--repeat,STDIN,count produced bad output">&2 ; }

# --repeat,stdin,count=0 should not fail and produce no output
#printf "A\nB\nC\nD\nE\n" | python3 shuf.py --rep -n0 > exp
# file size should be zero (no output from shuf)
#test \! -s exp ||
#    { fail=1; echo "--repeat,STDIN,-n0 produced bad output">&2 ; }

# shuf 8.25 mishandles input if stdin is closed, due to glibc bug#15589.
# See coreutils bug#25029.
#python3 shuf.py /dev/null <&- >out || fail=1
#compare /dev/null out || fail=1

exit $fail
