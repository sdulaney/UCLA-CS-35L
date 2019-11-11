#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void check_args(int arg_count, const char* arg_vector[])
{
    if (arg_count != 3)
    {
	char msg[] = "Error: wrong number of arguments (expected 2).\n";
	write(2, msg, sizeof(msg));
	exit(1);
    }
    const char* from = arg_vector[1];
    const char* to = arg_vector[2];
    if (strlen(from) != strlen(to))
    {
	char msg[] = "Error: arguments from and to must be the same length.\n";
	write(2, msg, sizeof(msg));
	exit(1);
    }
    for (int i = 0; i < strlen(from); i++)
    {
	for (int j = i + 1; j < strlen(from); j++)
	{
	    if (from[i] == from[j])
	    {
		char msg[] = "Error: argument from cannot contain duplicate bytes.\n";
		write(2, msg, sizeof(msg));
		exit(1);
	    }
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
	int temp = read(0, &ch, 1);
	const char* from = argv[1];
	const char* to = argv[2];
	
	if (temp != 1)
	{
	    break;
	}
	
	bool match = false;
	for (int i = 0; i < strlen(from); i++)
	{
	    if (ch == from[i])
	    {
		match = true;
		write(1, &to[i], 1);
	    }
	}
	if (match == false)
	{
	    write(1, &ch, 1);
	}
	
    }

    return 0;
}
