CC = gcc -g
INSTALLDIR = /usr/local/bin

all:
	$(CC) htksortdict.c -o htksortdict
	mkdir -p $(INSTALLDIR)
	install -p htksortdict $(INSTALLDIR)
	rm htksortdict

