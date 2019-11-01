#include <stdio.h>
#include <stdlib.h>
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
	if (a_unfrob > b_unfrob)
	{
	    return 1;
	}
	else if (a_unfrob < b_unfrob)
	{
	    return -1;
	}
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

// Wrapper of frobcmp using void pointers to pass to qsort.
int cmp(const void* x, const void* y)
{
    // Cast from void** to char** and then dereference.
    const char* a = *((const char**) x);
    const char* b = *((const char**) y);
    return frobcmp(a, b);
}

int main()
{
  // Unit tests for frobcmp 
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

  char** wordlist = NULL;
  int wordlist_len = 0;
  char* word = NULL;
  int word_len = 0;
  
  // Read from STDIN byte by byte until getchar returns EOF (indicating failure).
  int ch;
  while (ch = getchar())
  {
      if (ch != EOF)
      {
	  if (word == NULL)
	  {
	      word = (char*) malloc(sizeof(char));
	  }
	  else
	  {
	      word = (char*) realloc(word, (word_len + 1) * sizeof(char));
	  }
	  word[word_len] = ch;
	  word_len++;
      }
      if (ch == ' ' || (ch == EOF && word_len > 0))
      {
	  if (ch == EOF && word_len > 0)
	  {
	      word = (char*) realloc(word, (word_len + 1) * sizeof(char));
	      word[word_len] = ' ';
	      word_len++;
	  }
	  if (wordlist == NULL)
	  {
	      wordlist = (char**) malloc(sizeof(char*));
	  }
	  else
	  {
	      wordlist = (char**) realloc(wordlist, (wordlist_len + 1) * sizeof(char*));
	  }
          wordlist[wordlist_len] = word;
	  wordlist_len++;
	  word = NULL;
	  word_len = 0;
      }
      if (ch == EOF)
      {
	  break;
      }
  }

  qsort(wordlist, wordlist_len, sizeof(char*), cmp);

  for (int i = 0; i < wordlist_len; i++)
  {
      for (int j = 0; wordlist[i][j] != ' '; j++)
      {
	  putchar(wordlist[i][j]);
      }
      putchar(' ');
      free(wordlist[i]);
  }

  free(wordlist);
 
  
  return 0;
}
