# makefile for emacs, updated Sun Apr 28 17:59:07 EET DST 1996

SRC=ansi.c basic.c bind.c buffer.c crypt.c display.c eval.c exec.c \
	file.c fileio.c ibmpc.c input.c isearch.c line.c lock.c main.c \
	pklock.c posix.c random.c region.c search.c spawn.c tcap.c \
	termio.c vmsvt.c vt52.c window.c word.c

OBJ=ansi.o basic.o bind.o buffer.o crypt.o display.o eval.o exec.o \
	file.o fileio.o ibmpc.o input.o isearch.o line.o lock.o main.o \
	pklock.o posix.o random.o region.o search.o spawn.o tcap.o \
	termio.o vmsvt.o vt52.o window.o word.o

HDR=ebind.h edef.h efunc.h epath.h estruct.h evar.h

# DO NOT ADD OR MODIFY ANY LINES ABOVE THIS -- make source creates them

CC=gcc
CFLAGS=-O4
#CC=c89 +O3			# HP
#CFLAGS= -D_HPUX_SOURCE -DSYSV
#CFLAGS=-O4 -DSVR4		# Sun
#CFLAGS=-O -qchars=signed	# RS/6000
DEFINES=-DAUTOCONF -DPOSIX -DUSG  -include /usr/include/errno.h	# Linux
#DEFINES=-DAUTOCONF
#LIBS=-ltermcap			# BSD
#LIBS=-lcurses			# SYSV
#LIBS=-ltermlib
LIBS=-L/usr/lib/termcap -ltermcap
LFLAGS=-hbx
BINDIR=/usr/bin
LIBDIR=/usr/lib

em:	${OBJ}
	${CC} ${DEFINES} -o em ${OBJ} ${LIBS}

clean:
	rm -f core lintout makeout tags makefile.bak *.o

install: em
	strip em
	cp em ${BINDIR}
	cp emacs.hlp ${LIBDIR}
	cp emacs.rc ${LIBDIR}/.emacsrc
	chmod 755 ${BINDIR}/em
	chmod 644 ${LIBDIR}/emacs.hlp ${LIBDIR}/.emacsrc

lint:	${SRC}
	@rm -f lintout
	lint ${LFLAGS} ${SRC} >lintout
	cat lintout

errs:
	@rm -f makeout
	make em >makeout

tags:	${SRC}
	@rm -f tags
	ctags ${SRC}

source:
	@mv makefile makefile.bak
	@echo "# makefile for emacs, updated `date`" >makefile
	@echo '' >>makefile
	@echo SRC=`ls *.c` >>makefile
	@echo OBJ=`ls *.c | sed s/c$$/o/` >>makefile
	@echo HDR=`ls *.h` >>makefile
	@echo '' >>makefile
	@sed -n -e '/^# DO NOT ADD OR MODIFY/,$$p' <makefile.bak >>makefile

depend: ${SRC}
	@for i in ${SRC}; do\
	    cc ${DEFINES} -M $$i | sed -e 's, \./, ,' | grep -v '/usr/include' | \
	    awk '{ if ($$1 != prev) { if (rec != "") print rec; \
		rec = $$0; prev = $$1; } \
		else { if (length(rec $$2) > 78) { print rec; rec = $$0; } \
		else rec = rec " " $$2 } } \
		END { print rec }'; done >makedep
	@echo '/^# DO NOT DELETE THIS LINE/+2,$$d' >eddep
	@echo '$$r ./makedep' >>eddep
	@echo 'w' >>eddep
	@cp makefile makefile.bak
	@ed - makefile <eddep
	@rm eddep makedep
	@echo '' >>makefile
	@echo '# DEPENDENCIES MUST END AT END OF FILE' >>makefile
	@echo '# IF YOU PUT STUFF HERE IT WILL GO AWAY' >>makefile
	@echo '# see make depend above' >>makefile

.c.o:
	${CC} ${CFLAGS} ${DEFINES} -c $*.c

# DO NOT DELETE THIS LINE -- make depend uses it

ansi.o: ansi.c estruct.h edef.h
basic.o: basic.c estruct.h edef.h
bind.o: bind.c estruct.h edef.h epath.h
buffer.o: buffer.c estruct.h edef.h
crypt.o: crypt.c estruct.h edef.h
display.o: display.c estruct.h edef.h
eval.o: eval.c estruct.h edef.h evar.h
exec.o: exec.c estruct.h edef.h
file.o: file.c estruct.h edef.h
fileio.o: fileio.c estruct.h edef.h
ibmpc.o: ibmpc.c estruct.h edef.h
input.o: input.c estruct.h edef.h
isearch.o: isearch.c estruct.h edef.h
line.o: line.c estruct.h edef.h
lock.o: lock.c estruct.h edef.h
main.o: main.c estruct.h efunc.h edef.h ebind.h
pklock.o: pklock.c estruct.h
random.o: random.c estruct.h edef.h
region.o: region.c estruct.h edef.h
search.o: search.c estruct.h edef.h
spawn.o: spawn.c estruct.h edef.h
tcap.o: tcap.c estruct.h edef.h
termio.o: termio.c estruct.h edef.h
vmsvt.o: vmsvt.c estruct.h edef.h
vt52.o: vt52.c estruct.h edef.h
window.o: window.c estruct.h edef.h
word.o: word.c estruct.h edef.h

# DEPENDENCIES MUST END AT END OF FILE
# IF YOU PUT STUFF HERE IT WILL GO AWAY
# see make depend above
