#!/bin/sh

# Using c11 per Piazza: https://piazza.com/class/k0zogkkf73r5dj?cid=310
gcc -std=c11 tr2b.c -o tr2b

##### Test 1: Test case given on Piazza.
test=1
echo 'ab\[-c' | ./tr2b 'a\[-' 'ptsd' > out
test $? -eq 0 || echo "Test $test: wrong exit code"
echo 'pbtsdc' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 2: Valid input.
test=2
echo '12321' | ./tr2b '12' 'ab' > out
test $? -eq 0 || echo "Test $test: wrong exit code"
echo 'ab3ba' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 3: Empty strings.
test=3
echo '12321' | ./tr2b '' '' > out
test $? -eq 0 || echo "Test $test: wrong exit code"
echo '12321' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

##### Test 4: from and to are not the same length (to longer).
test=4
echo '12321' | ./tr2b '12' 'abc' > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

##### Test 5: from and to are not the same length (from longer).
test=5
echo '12321' | ./tr2b '123' 'ab' > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

##### Test 6: from has duplicate bytes.
test=6
echo '12321' | ./tr2b '212' 'abc' > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

##### Test 7: wrong number of operands (too few).
test=7
echo '12321' | ./tr2b '212' > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"

##### Test 8: wrong number of operands (too many).
test=8
echo '12321' | ./tr2b '212' 'abc' 'def' > out.1 2> out.2
test $? -eq 1 || echo "Test $test: wrong exit code"
cmp -s out.2 /dev/null && echo "Test $test: STDERR empty"
cmp out.1 /dev/null || echo "Test $test: STDOUT not empty"


