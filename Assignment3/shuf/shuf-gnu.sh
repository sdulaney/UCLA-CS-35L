#!/bin/sh
# Test that shuf.py meets the spec for Assignment 3.
# Assumes the exit status 2 returned by OptionParser.error() is the only code indicating failure for shuf.py.
fail=0

seq 100 > in

########## START: Hard requirements from the spec ##############################

##### Input mode 1: STDIN

# no FILE, 0 option arguments
cat in | shuf >out || fail=1
c=$(wc -l < out)
test "$c" -eq 100 || { fail=1; echo "no FILE, 0 option arguments failed">&2 ; }

# Fail if the input is the same as the output.
# This is a probabilistic test :-)
# However, the odds of failure are very low: 1 in 100! (~ 1 in 10^158)
cmp in out > /dev/null && { fail=1; echo "not random?" 1>&2; }

# Fail if the sorted output is not the same as the input.
sort -n out > out1
cmp in out1 > /dev/null || { fail=1; echo "not a permutation" 1>&2; }

# FILE is -, 0 option arguments
cat in | shuf - >out || fail=1
c=$(wc -l < out)
test "$c" -eq 100 || { fail=1; echo "FILE is -, 0 option arguments failed">&2 \
; }

# Fail if the input is the same as the output.
# This is a probabilistic test :-)
# However, the odds of failure are very low: 1 in 100! (~ 1 in 10^158)
cmp in out > /dev/null && { fail=1; echo "not random?" 1>&2; }

# Fail if the sorted output is not the same as the input.
sort -n out > out1
cmp in out1 > /dev/null || { fail=1; echo "not a permutation" 1>&2; }

##### Input mode 2: FILE

# FILE is not -, 0 option arguments
shuf in >out || fail=1
c=$(wc -l < out)
test "$c" -eq 100 || { fail=1; echo "FILE is not -, 0 option arguments failed">&2 \
; }

# Fail if the input is the same as the output.
# This is a probabilistic test :-)
# However, the odds of failure are very low: 1 in 100! (~ 1 in 10^158)
cmp in out > /dev/null && { fail=1; echo "not random?" 1>&2; }

# Fail if the sorted output is not the same as the input.
sort -n out > out1
cmp in out1 > /dev/null || { fail=1; echo "not a permutation" 1>&2; }

# Test file does not exist fails
shuf in1 >out 2>out.2
test $? -ne 0 || fail=1

# Test file missing read permissions fails
touch in1
chmod -r in1
shuf in1 >out 2>out.2
test $? -ne 0 || fail=1
rm in1

# Test multiple non-option arguments fails
shuf in in1 >out 2>out.2
test $? -ne 0 || fail=1

##### Input mode 3: option -i (Act as if input came from a file containing the range of unsigned decimal integers lo...hi, one per line.)

# Exercise shuf's -i option.
shuf -i 1-100 > out || fail=1
cmp in out > /dev/null && { fail=1; echo "not random?" 1>&2; }
sort -n out > out1
cmp in out1 > /dev/null || { fail=1; echo "not a permutation" 1>&2; }

# Test invalid range for -i
for ARG in '1' 'A' '1-' '1-A' '3-1'; do
    { shuf -i$ARG > out 2> out.2 || test $? -eq 0; } &&
    { fail=1; echo "shuf did not detect erroneous -i$ARG usage.">&2 ; }
done

# -i cannot be used with any non-option arguments
shuf -i 1-100 - > out 2> out.2
test $? -ne 0 || fail=1
shuf -i 1-100 in > out 2> out.2
test $? -ne 0 || fail=1
touch in2
shuf -i 1-100 in in2 > out 2> out.2
test $? -ne 0 || fail=1
rm in2

##### Option --head-count (-n)

# Exercise shuf's -n option.
shuf -i 1-100 -n 9 > out || fail=1
c=$(wc -l < out)
test "$c" -eq 9 || { fail=1; echo "Option -n failed">&2 ; }

# Test invalid arguments for option -n
shuf in -n A >out 2>out.2
test $? -ne 0 || fail=1
shuf in -n -1 >out 2>out.2
test $? -ne 0 || fail=1

##### Option --repeat (-r)

# Exercise shuf's -r option.
shuf -i 1-10 -n 100 -r > out || fail=1
c=$(wc -l < out)
test "$c" -eq 100 || { fail=1; echo "Option -r failed">&2 ; }

##### Option --help

# Exercise shuf's --help option.
#shuf --help > out || fail=1
#cmp out shuf--help.txt || { fail=1; echo "Option --help failed">&2 ; }

# Test option -i with missing mandatory argument fails
shuf -i > /dev/null 2> /dev/null
test $? -ne 0 || fail=1

# Test option -n with missing mandatory argument fails
shuf -n > /dev/null 2> /dev/null
test $? -ne 0 || fail=1





########## END: Hard requirements from the spec ################################



# TODO: Test the output with the -r option is not a permutation of the input?




# Your program should support zero non-option arguments (means read from standard input) - 1 options
cat in | shuf -i 0-9 >out || fail=1
c=$(wc -l < out)
test "$c" -eq 10 || { fail=1; echo "Zero non-option arguments and one option arguments failed (-i should override no FILE and not read from STDIN)">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 2 options
cat in | shuf -r -n 1000 >out || fail=1
c=$(wc -l < out)
test "$c" -eq 1000 || { fail=1; echo "Zero non-option arguments and two option arguments failed">&2 ; }

# Your program should support zero non-option arguments (means read from standard input) - 3 options
cat in | shuf -r -n 1000 -i 0-9 >out || fail=1
c=$(sort -u < out | wc -l)
test "$c" -eq 10 || { fail=1; echo "Zero non-option arguments and three  option arguments failed (-i should override no FILE and not read from STDIN)">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 0 options
cat in | shuf - >out || fail=1
c=$(wc -l < out)
test "$c" -eq 100 || { fail=1; echo "Single non-option argument "-" and zero option arguments failed">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 1 options (option -i and FILE equal to - should crash the program)
cat in | shuf - -i 0-9 >out 2> /dev/null
test $? -ne 0 || fail=1

# Your program should support a single non-option argument "-" (means read from standard input) - 2 options
cat in | shuf - -r -n 1000 >out || fail=1
c=$(wc -l < out)
test "$c" -eq 1000 || { fail=1; echo "Single non-option argument "-" and two option arguments failed">&2 ; }

# Your program should support a single non-option argument "-" (means read from standard input) - 3 options (option -i and FILE equal to - should crash the program)
cat in | shuf - -r -n 1000 -i 0-9 >out 2> /dev/null
test $? -ne 0 || fail=1

# Invalid arguments
shuf -r /dev/null > /dev/null 2> /dev/null
test $? -ne 0 || fail=1

# Invalid arguments: with a single redundant operand with --input-range
shuf -i0-0 1 > /dev/null 2> /dev/null
test $? -ne 0 || fail=1

# Avoid infloop.
# "seq 1860" produces 8193 (8K + 1) bytes of output.
seq 1860 | shuf > /dev/null || fail=1



# Ensure shuf -n operates efficiently for small n. Before coreutils-8.13
# this would try to allocate $SIZE_MAX * sizeof(size_t)
#timeout 10 shuf -i1-$SIZE_MAX -n2 >/dev/null ||
#    { fail=1; echo "couldn't get a small subset" >&2; }

# Ensure shuf -n0 doesn't read any input or open specified files
touch unreadable
chmod 0 unreadable
if ! test -r unreadable; then
  shuf -n0 unreadable || fail=1  
  { shuf -n1 unreadable > /dev/null 2> /dev/null || test $? -ne 1; } && fail=1
fi
shuf -n0 < /dev/null || fail=1



# Multiple -n is accepted, should use the smallest value
#shuf -n10 -i0-9 -n3 -n20 > exp
#c=$(wc -l < exp)
#test "$c" -eq 3 || { fail=1; echo "Multiple -n failed">&2 ; }

# Test error conditions

# Test invalid value for -n
{ cat in | shuf -nA > /dev/null 2> /dev/null || test $? -eq 0; } &&
    { fail=1; echo "shuf did not detect erroneous -n usage.">&2 ; }

# Test multiple -i
#{ shuf -i0-9 -n10 -i8-90 || test $? -ne 2; } &&
#  { fail=1; echo "shuf did not detect multiple -i usage.">&2 ; }

# Test --repeat option

# --repeat can output more values than the input range
shuf --rep -i0-9 -n1000 > exp
c=$(wc -l < exp)
test "$c" -eq 1000 || { fail=1; echo "--repeat with --count failed">&2 ; }

# Check output values (this is not bullet-proof, but drawing 1000 values
# between 0 and 9 should produce all values, unless there's a bug in shuf
# or a very poor random source, or extremely bad luck)
c=$(sort -nu exp | paste -s -d ' ')
test "$c" = "0 1 2 3 4 5 6 7 8 9" ||
    { fail=1; echo "--repeat produced bad output">&2 ; }

# check --repeat with non-zero low value
shuf --rep -i222-233 -n2000 > exp
c=$(sort -nu exp | paste -s -d ' ')
test "$c" = "222 223 224 225 226 227 228 229 230 231 232 233" ||
 { fail=1; echo "--repeat produced bad output with non-zero low">&2 ; }

# --repeat,-i,count=0 should not fail and produce no output
shuf --rep -i0-9 -n0 > exp || fail=1
# file size should be zero (no output from shuf)
test \! -s exp ||
    { fail=1; echo "--repeat,-i0-9,-n0 produced bad output">&2 ; }

# --repeat,FILE,count=0 should not fail and produce no output
#shuf -r -n0 in > exp || fail=1
# file size should be zero (no output from shuf)
#test \! -s exp ||
#    { fail=1; echo "--repeat,FILE,-n0 produced bad output">&2 ; }

# --repeat with STDIN, without count, should repeat indefinitely
#printf "A\nB\nC\nD\nE\n" | shuf --rep | head -n 1000 > exp
#c=$(wc -l < exp)
#test "$c" -eq 1000 ||
#  { fail=1; echo "--repeat,STDIN does not repeat indefinitely">&2 ; }

# --repeat with STDIN,count - can return more values than input lines
printf "A\nB\nC\nD\nE\n" | shuf --rep -n2000 > exp
c=$(wc -l < exp)
test "$c" -eq 2000 ||
    { fail=1; echo "--repeat,STDIN,count failed">&2 ; }

# Check output values (this is not bullet-proof, but drawing 2000 values
# between A and E should produce all values, unless there's a bug in shuf
# or a very poor random source, or extremely bad luck)
c=$(sort -u exp | paste -s -d ' ')
test "$c" = "A B C D E" ||
  { fail=1; echo "--repeat,STDIN,count produced bad output">&2 ; }

# --repeat,stdin,count=0 should not fail and produce no output
printf "A\nB\nC\nD\nE\n" | shuf --rep -n0 > exp || fail=1
# file size should be zero (no output from shuf)
test \! -s exp ||
    { fail=1; echo "--repeat,STDIN,-n0 produced bad output">&2 ; }

# shuf 8.25 mishandles input if stdin is closed, due to glibc bug#15589.
# See coreutils bug#25029.
shuf /dev/null <&- >out || fail=1
cmp /dev/null out || fail=1

echo $fail
exit $fail
