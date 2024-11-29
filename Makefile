CC=gcc217
FLAGS=-g

# Dependency rules for non-file targets
all: createtests mywcc mywcs fib_good fib

clean:
	rm mywc*.txt
	rm mywcc
	rm mywcs
	rm createtests
	rm -f fib*.out
	rm fib_good fib

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

fib.o: fib.c
	$(CC) $(FLAGS) fib.c -c

bigintadd_good.o: bigintadd.c
	$(CC) $(FLAGS) bigintadd_good.c -c 

bigintadd.o: bigintadd.s
	$(CC) $(FLAGS) bigintadd.s -c

bigint.o: bigint.c
	$(CC) $(FLAGS) bigint.c -c

fib_good: bigint.o bigintadd_good.o fib.o
	$(CC) $(FLAGS) bigint.o bigintadd_good.o fib.o -o fib_good

fib: bigint.o bigintadd.o fib.o
	$(CC) $(FLAGS) bigint.o bigintadd.o fib.o -o fib

.PHONY: all clobber clean
