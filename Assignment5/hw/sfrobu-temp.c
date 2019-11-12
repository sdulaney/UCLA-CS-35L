#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <stdbool.h>

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

void free_memory(char** wordlist, int wordlist_len)
{
    for (int i = 0; i < wordlist_len; i++)
    {
	free(wordlist[i]);
    }
    free(wordlist);
}

void check_mem_alloc_error(void* ptr, char** wordlist, int wordlist_len)
{
    if (ptr == NULL)
    {
	free_memory(wordlist, wordlist_len);
	char msg[] = "Memory allocation error.\n";
	write(2, &msg, sizeof(msg));
        exit(1);
    }
}


int main()
{
  char** wordlist = NULL;
  int wordlist_len = 0;
  char* word = NULL;
  int word_len = 0;
  
  struct stat fileS;
  char* input = NULL;
  int input_size = 0;
  int num_words = 0;

  if (fstat(0, &fileS) < 0)
  {
      char msg[] = "Unable to read file info.\n";
      write(2, &msg, sizeof(msg));
      exit(1);
  }

  // If standard input is a regular file, your program should initially allocate enough memory to hold all the data in that file all at once.
/*  if (S_ISREG(fileS.st_mode))
  {   
      // Handle empty files.
      if (fileS.st_size == 0)
      {
	  return 0;
      }

      input = (char*) malloc(fileS.st_size * sizeof(char));
      check_mem_alloc_error(input, wordlist, wordlist_len);
      input_size = fileS.st_size;

      int temp = read(0, input, fileS.st_size);
      if (temp == -1)
      {
	  free_memory(wordlist, wordlist_len);
	  char msg[] = "Input error.\n";
	  write(2, &msg, sizeof(msg));
	  exit(1);
      }

      // Append trailing space if missing.
      if (input[input_size - 1] != ' ')
      {
	  input = (char*) realloc(input, (fileS.st_size + 1) * sizeof(char));
	  check_mem_alloc_error(input, wordlist, wordlist_len);
	  input_size = fileS.st_size + 1;
	  input[input_size - 1] = ' ';
      }

      // Count number of spaces so we can allocate wordlist with enough memory to hold pointers to all the words in the file.
      for (int i = 0; i < fileS.st_size; i++)
      {
	  if (input[i] == ' ')
	  {
	      num_words++;
	  }
      }

      wordlist = (char**) malloc(num_words * sizeof(char*));
      check_mem_alloc_error(wordlist, wordlist, wordlist_len);
      wordlist_len = num_words;

      int j = 0;
      bool finishing_word = false;
      for (int i = 0; i < input_size; i++)
      {
	  if (!finishing_word)
	  {
	      wordlist[j++] = &input[i];
	      finishing_word = true;
	  }
	  if (input[i] == ' ')
	  {
	      finishing_word = false;
	  }
      }
  }
  else
  {*/
  // Read from STDIN byte by byte.
  int ch;
  while (1)
  {
      int temp = read(0, &ch, 1);

      if (temp == -1)
      {
	  free_memory(wordlist, wordlist_len);
	  char msg[] = "Input error.\n";
	  write(2, &msg, sizeof(msg));
	  exit(1);
      }
      
      if (temp == 0)
      {
	  break;
      }
      
      if (word == NULL)
      {
	  word = (char*) malloc(sizeof(char));
	  check_mem_alloc_error(word, wordlist, wordlist_len);
      }
      else
      {
	  word = (char*) realloc(word, (word_len + 1) * sizeof(char));
	  check_mem_alloc_error(word, wordlist, wordlist_len);
      }
      word[word_len] = ch;
      word_len++;

      if (ch == ' ')
      {
	  if (wordlist == NULL)
	  {
	      wordlist = (char**) malloc(sizeof(char*));
	      check_mem_alloc_error(wordlist, wordlist, wordlist_len);
	  }
	  else
	  {
	      wordlist = (char**) realloc(wordlist, (wordlist_len + 1) * sizeof(char*));
	      check_mem_alloc_error(wordlist, wordlist, wordlist_len);
	  }
          wordlist[wordlist_len] = word;
	  wordlist_len++;
	  word = NULL;
	  word_len = 0;
      }
  }

  if (word_len > 0)
  {
      word = (char*) realloc(word, (word_len + 1) * sizeof(char));
      check_mem_alloc_error(word, wordlist, wordlist_len);
      word[word_len] = ' ';
      word_len++;
      if (wordlist == NULL)
      {
	  wordlist = (char**) malloc(sizeof(char*));
	  check_mem_alloc_error(wordlist, wordlist, wordlist_len);
      }
      else
      {
	  wordlist = (char**) realloc(wordlist, (wordlist_len + 1) * sizeof(char*));
	  check_mem_alloc_error(wordlist, wordlist, wordlist_len);
      }
      wordlist[wordlist_len] = word;
      wordlist_len++;
      word = NULL;
      word_len = 0;
  }
  // }
  
  qsort(wordlist, wordlist_len, sizeof(char*), cmp);

  for (int i = 0; i < wordlist_len; i++)
  {
      for (int j = 0; wordlist[i][j] != ' '; j++)
      {
	  write(1, &wordlist[i][j], 1);
      }
      char temp[] = " ";
      write(1, &temp, 1);
  }

  free_memory(wordlist, wordlist_len); 
  
  return 0;
}
