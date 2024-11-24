CC=gcc217
FLAGS=-g

# Dependency rules for non-file targets
all: createtests mywcc mywcs

clean:
	rm mywc*.txt
	rm mywcc
	rm mywcs
	rm createtests

clobber: clean
	rm -f *~ \#*\#


# Dependency rules for file targets
tester.o: tester.c
	$(CC) $(FLAGS) -c tester.c

createtests: tester.o
	$(CC) $(FLAGS) tester.o -o createtests

mywc.o: mywc.c
	$(CC) $(FLAGS) -c mywc.c

mywcc: mywc.o
	$(CC) $(FLAGS) mywc.o -o mywcc

mywc_asm.o: mywc_asm.s
	$(CC) $(FLAGS) -c mywc_asm.s

mywcs: mywc_asm.o
	$(CC) $(FLAGS) mywc_asm.o -o mywcs


.PHONY: all clobber clean
