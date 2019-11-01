#!/bin/sh

# Using default C version per Piazza: https://piazza.com/class/k0zogkkf73r5dj?cid=268
# __STDC_VERSION__ is 201710 (c17, a bugfix version of c11)
gcc -g -O0 sfrob.c -o sfrob

# Test case given in spec.
test=1
printf '*~BO *{_CIA *hXE]D *LER #@_GZY #E\\OX #^BO #FKPS #NEM\4' | ./sfrob | od -ta > out
test $? -eq 0 || echo "Test $test: wrong exit code"
echo '0000000   *   h   X   E   ]   D  sp   *   {   _   C   I   A  sp   *   ~
0000020   B   O  sp   *   L   E   R  sp   #   N   E   M eot  sp   #   @
0000040   _   G   Z   Y  sp   #   F   K   P   S  sp   #   E   \   O   X
0000060  sp   #   ^   B   O  sp
0000066' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

# Test input error (when STDIN is closed).
test=2
./sfrob <&- > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp out.2 /dev/null && echo "Test $test: wrong STDERR"
