DEBUG=n

CFILES=craps.c shooter.c
EXEFILES=$(subst .c,,$(CFILES))

CC=gcc
CFLAGS=-Wall 
LDFLAGS= 

ifeq ($(DEBUG), y)
	CFLAGS += -DDEBUG -g 
else
	CFLAGS += -O2
endif

all: craps shooter

craps: craps.o common.o

shooter: shooter.o common.o

clean:
	$(RM) *~ *.o *.d $(EXEFILES)

pack: clean
	echo tar -czvf ${USER}-lab1-sumbit.tar.gz *.c *.h Makefile

depend .depend dep:
	$(CC) $(CFLAGS) -M *.c > .depend

.PHONY: all clean pack

%.o: %.c
	gcc -c $(CFLAGS) $*.c -o $*.o
	gcc -MM $(CFLAGS) $*.c > $*.d
	@mv -f $*.d $*.d.tmp
	@sed -e 's|.*:|$*.o:|' < $*.d.tmp > $*.d
	@sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
	sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
	@rm -f $*.d.tmp

-include $(SRCS:%.c=%.d)
