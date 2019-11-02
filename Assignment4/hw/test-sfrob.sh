#!/bin/sh

option=$1

# Using default C version per Piazza: https://piazza.com/class/k0zogkkf73r5dj?cid=268
# __STDC_VERSION__ is 201710 (c17, a bugfix version of c11)
gcc sfrob.c -o sfrob

##### Test 1: Test case given in spec.
test=1
printf '*~BO *{_CIA *hXE]D *LER #@_GZY #E\\OX #^BO #FKPS #NEM\4' | ./sfrob | od -ta > out
test $? -eq 0 || echo "Test $test: wrong exit code"
echo '0000000   *   h   X   E   ]   D  sp   *   {   _   C   I   A  sp   *   ~
0000020   B   O  sp   *   L   E   R  sp   #   N   E   M eot  sp   #   @
0000040   _   G   Z   Y  sp   #   F   K   P   S  sp   #   E   \   O   X
0000060  sp   #   ^   B   O  sp
0000066' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 2: Expect the same output as Test 1 when there is a trailing space.
test=2
printf '*~BO *{_CIA *hXE]D *LER #@_GZY #E\\OX #^BO #FKPS #NEM\4 ' | ./sfrob | od -ta > out
test $? -eq 0 || echo "Test $test: wrong exit code"
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 3: Test on empty file.
test=3
touch empty
cat empty | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
cmp empty out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 4: Test on relatively large file (rt1.jar - /usr/local/cs/jdk1.8.0_31/jre/lib/rt.jar).
test=4
cat rt1.jar | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
# out should be the same size or 1 byte larger than rt1.jar (when append trailing space)
rt1_size=$(stat -c%s rt1.jar)
out_size=$(stat -c%s out)
size_difference=$(($out_size-$rt1_size))
test $size_difference -eq 0 || test $size_difference -eq 1 || echo "Test $test: wrong STDOUT"

##### Test 5: Test on relatively large file (rt2.jar - /usr/local/cs/jdk1.8.0_45/jre/lib/rt.jar).
test=5
cat rt2.jar | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
# out should be the same size or 1 byte larger than rt2.jar (when append trailing space)
rt2_size=$(stat -c%s rt2.jar)
out_size=$(stat -c%s out)
size_difference=$(($out_size-$rt2_size))
test $size_difference -eq 0 || test $size_difference -eq 1 || echo "Test $test: wrong STDOUT"

##### Test 6: Test input error (when STDIN is closed).
test=6
./sfrob <&- > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

# Note: could not simulate this error by closing STDOUT.
##### Test 7: Test output error (when STDOUT is closed).
#test=7
#printf '*~BO *{_CIA *hXE]D *LER #@_GZY #E\\OX #^BO #FKPS #NEM\4' | ./sfrob >&- > out.1 2> out.2
#test $? -eq 1 || echo "Test $test: wrong exit code"
#cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
#cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

##### Test 8: consecutive spaces should be treated as blank lines.
test=8
printf '*~BO *{_CIA *hXE]D *LER #@_GZY     #E\\OX #^BO #FKPS #NEM\4' | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
printf '    *hXE]D *{_CIA *~BO *LER #NEM\4 #@_GZY #FKPS #E\OX #^BO ' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 9: only spaces in input.
test=9
printf '     ' | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
printf '     ' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

# Note: STDOUT not tested.
##### Test 10: your program should work on the file /proc/self/status, a "file" that is constantly mutating.
test=10
cat /proc/self/status | ./sfrob > out
test $? -eq 0 || echo "Test $test: wrong exit code"
#printf '     ' > expected_output
#cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"
