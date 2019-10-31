#include <stdio.h>
#include <assert.h>

// Returns a value that is negative, zero, or positive depending on whether a is less than, equal to, or greater than b. 
int frobcmp(char const * a, char const * b)
{
  while (*a != ' ' && *b != ' ')
  {
    if (*a != *b)
    {
	char a_unfrob = *a ^ 0b00101010;
	char b_unfrob = *b ^ 0b00101010;
	return a_unfrob - b_unfrob;
    }
    a++;
    b++;
  }

  if (*a == ' ' && *b == ' ')
  {
      return 0;
  }
  if (*a == ' ')
  {
      return -1;
  }
  if (*b == ' ')
  {
      return 1;
  }
}

int main()
{
  // a > b
  assert(frobcmp("*{_CIA\030\031 ", "*`_GZY\v ") > 0);
  // a < b
  assert(frobcmp("*k_CIA\030\031 ", "*`_GZY\v ") < 0);
  // a = b
  assert(frobcmp("*{_CIA\030\031 ", "*{_CIA\030\031 ") == 0);
  // 1st arg is space byte: a < b
  assert(frobcmp(" ", "*`_GZY\v ") < 0);
  // 2nd arg is space byte: a > b
  assert(frobcmp("*{_CIA\030\031 ", " ") > 0);
  // 1st arg is prefix of 2nd: a < b
  assert(frobcmp("*{_CIA ", "*{_CIA\030\031 ") < 0);
  // 2nd arg is prefix of 1st: a > b
  assert(frobcmp("*{_CIA\030\031 ", "*{_CIA ") > 0);
  // null byte in 1st arg contributes to comparison
  assert(frobcmp("{_CIA*\031 ", "{_CIA\030\031 ") < 0);
  // null byte in 2nd arg contributes to comparison
  assert(frobcmp("{_CIA\030\031 ", "{_CIA*\031 ") > 0);
  
  

  
 
  
  return 0;
}
