randmain: randmain.o randcpuid.o
	$(CC) $(CFLAGS) -ldl -Wl,-rpath=$(PWD) randmain.o randcpuid.o -o $@

randlibhw.o: randlibhw.c
	$(CC) $(CFLAGS) -fPIC -c randlibhw.c -o randlibhw.o

randlibhw.so: randlibhw.o
	$(CC) $(CFLAGS) -shared randlibhw.o -o $@

randlibsw.o: randlibsw.c
	$(CC) $(CFLAGS) -fPIC -c randlibsw.c -o randlibsw.o

randlibsw.so: randlibsw.o
	$(CC) $(CFLAGS) -shared randlibsw.o -o $@

