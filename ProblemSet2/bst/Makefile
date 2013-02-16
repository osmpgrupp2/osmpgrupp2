#
# Makefile for lab2 in Process Oriented Programming
#
# Course: Operating Systems and Multicore Programming - OSM-vt13
# Lab assignment 2: A thread-safe binary search tree
#
# Author: Nikos Nikoleris <nikos.nikoleris@it.uu.se>
#

# change to y to enable debugging support
DEBUG:=

CFLAGS=-pthread -Wall -Wextra -std=c99 -D_XOPEN_SOURCE=600
LDFLAGS=-pthread -lrt

CC=gcc

ifeq ($(DEBUG), y)
	CFLAGS += -g
	LDFLAGS += -g
else
	CFLAGS += -O2
	LDFLAGS += -O2
endif

all: bst_test

bst_test: bst_test.o bst.o timing.o

clean:
	$(RM) *.o *.d *~

distclean: clean
	$(RM) bst_test

.PHONY: all clean distclean

%.o: %.c
	$(CC) -c $(CFLAGS) $*.c -o $*.o
	$(CC) -MM $(CFLAGS) $*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@$(RM) $*.d.tmp

-include $(wildcard *.d)
