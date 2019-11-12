#include <unistd.h>
#include <stdlib.h>

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
