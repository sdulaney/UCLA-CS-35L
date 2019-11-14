#include "randcpuid.h"
#include <stdbool.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

static bool
writebytes (unsigned long long x, int nbytes)
{
  int ndigits = nbytes * 2;
  do
    {
      if (putchar ("0123456789abcdef"[x & 0xf]) < 0)
	return false;
      x >>= 4;
      ndigits--;
    }
  while (0 < ndigits);

  return 0 <= putchar ('\n');
}

/* Main program, which outputs N bytes of random data.  */
int
main (int argc, char **argv)
{
  /* Check arguments.  */
  bool valid = false;
  long long nbytes;
  if (argc == 2)
    {
      char *endptr;
      errno = 0;
      nbytes = strtoll (argv[1], &endptr, 10);
      if (errno)
	perror (argv[1]);
      else
	valid = !*endptr && 0 <= nbytes;
    }
  if (!valid)
    {
      fprintf (stderr, "%s: usage: %s NBYTES\n", argv[0], argv[0]);
      return 1;
    }

  /* If there's no work to do, don't worry about which library to use.  */
  if (nbytes == 0)
    return 0;

  /* Now that we know we have work to do, arrange to use the
     appropriate library.  */
  void* handle;
  unsigned long long (*rand64) (void);
  char* error;

  if (rdrand_supported ())
    {
	handle = dlopen("randlibhw.so", RTLD_NOW);
	if (!handle)
	{
	    fprintf(stderr, "Error: dlopen failed with error %s.\n", dlerror());
	    exit(1);
	}
	rand64 = dlsym(handle, "rand64");
	error = dlerror();
	if (error != NULL)
	{
	    fprintf(stderr, "Error: dlsym failed with error %s.\n", error);
	    exit(1);
	}
    }
  else
    {
	handle = dlopen("randlibsw.so", RTLD_NOW);
	if (!handle)
	{
	    fprintf(stderr, "Error: dlopen failed with error %s.\n", dlerror());
	    exit(1);
	}
	rand64 = dlsym(handle, "rand64");
	error = dlerror();
	if (error != NULL)
	{
	    fprintf(stderr, "Error: dlsym failed with error %s.\n", error);
	    exit(1);
	}
    }

  int wordsize = sizeof rand64 ();
  int output_errno = 0;

  do
    {
      unsigned long long x = rand64 ();
      int outbytes = nbytes < wordsize ? nbytes : wordsize;
      if (!writebytes (x, outbytes))
	{
	  output_errno = errno;
	  break;
	}
      nbytes -= outbytes;
    }
  while (0 < nbytes);

  if (fclose (stdout) != 0)
    output_errno = errno;

  if (output_errno)
    {
      errno = output_errno;
      perror ("output");
      return 1;
    }

  int dlclose_ret_code = dlclose(handle);
  if (dlclose_ret_code != 0)
  {
      fprintf(stderr, "Error: dlclose failed with error code %d.\n", dlclose_ret_code);
      exit(1);
  }

  return 0;
}
