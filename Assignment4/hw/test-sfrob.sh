#!/bin/sh

test=1
printf '*~BO *{_CIA *hXE]D *LER #@_GZY #E\\OX #^BO #FKPS #NEM\4' | ./sfrob | od -ta > out
test $? -eq 0 || echo "Test $test: wrong exit code"
cat '0000000   *   h   X   E   ]   D  sp   *   {   _   C   I   A  sp   *   ~
0000020   B   O  sp   *   L   E   R  sp   #   N   E   M eot  sp   #   @
0000040   _   G   Z   Y  sp   #   F   K   P   S  sp   #   E   \   O   X
0000060  sp   #   ^   B   O  sp
0000066' > expected_output
cmp expected_output out > /dev/null || echo "Test $test: wrong STDOUT"

