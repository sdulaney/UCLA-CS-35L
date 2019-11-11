#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void check_args(int arg_count, const char* arg_vector[])
{
    if (arg_count != 3)
    {
	fprintf(stderr, "Error: wrong number of arguments (expected 2).\n");
	exit(1);
    }
    const char* from = arg_vector[1];
    const char* to = arg_vector[2];
    if (strlen(from) != strlen(to))
    {
	fprintf(stderr, "Error: arguments from and to must be the same length.\n");
	exit(1);
    }
    for (int i = 0; i < strlen(from); i++)
    {
	for (int j = i + 1; j < strlen(from); j++)
	{
	    if (from[i] == from[j])
	    {
		fprintf(stderr, "Error: argument from cannot contain duplicate bytes.\n");
		exit(1);
	    }
	}
    }
}

void check_output_error(int ret_code)
{
    if (ret_code == EOF)
    {
	if (ferror(stdout))
	{
	    fprintf(stderr, "Output error.\n");
	    exit(1);
	}
    }
}

int main(int argc, const char* argv[])
{
    check_args(argc, argv);

    // Read from STDIN byte by byte.
    int ch;
    
    while (1)
    {
	ch = getchar();
	const char* from = argv[1];
	const char* to = argv[2];
	
	// If getchar failed due to an error besides end-of-file condition
	if (ferror(stdin))
	{
	    fprintf(stderr, "Input error.\n");
	    exit(1);
	}

	// If getchar failed due to end-of-file condition
	if (feof(stdin))
	{
	    break;
	}
	
	bool match = false;
	int putchar_ret_code = 0;
	for (int i = 0; i < strlen(from); i++)
	{
	    if (ch == from[i])
	    {
		match = true;
		putchar_ret_code = putchar(to[i]);
		check_output_error(putchar_ret_code);
	    }
	}
	if (match == false)
	{
	    putchar_ret_code = putchar(ch);
	    check_output_error(putchar_ret_code);
	}
	
    }

    return 0;
}
