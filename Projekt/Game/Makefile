# Tex settings
ERLANG_COMPILER = erlc
JAVA_GO 	= java
JAVA_COMPILER   = javac
ERLANG_EXTRA 	= -classpath .:/usr/lib/erlang/lib/jinterface-1.5.4/priv/OtpErlang.jar


# Clean settings
GEN_EXTENSIONS = *.beam *.dump

ERL_FILES := $(wildcard *.erl)
BEAM_FILES := $(patsubst %.erl,%.beam,${ERL_FILES})


comma:= ,
empty:=
space:= $(empty) $(empty)


EDOC_SRC := $(filter-out %_test.erl, $(ERL_FILES))
EDOC_SRC_LIST := [$(subst $(space),$(comma),$(patsubst %.erl,'%.erl', $(EDOC_SRC)))]

# Remember: $< expands to dependent file
#           $@ expands to target file

clean:
	rm $(GEN_EXTENSIONS)
	rm bin/$(GEN_EXTENSIONS)
	rm src/$(GEN_EXTENSIONS)

cleandoc:
	(cd doc/html && find . -name "*" -a ! -name overview.edoc -exec rm -rf {} \;)
	(cd doc/javahtml && find . -name "*" -a ! -name overview.edoc -exec rm -rf {} \;)
beautify:
	astyle -A7 *.c *.h

oldcompilerjava: src/*.java
	$(JAVA_COMPILER) $(ERLANG_EXTRA) src/*.java
oldgojava: oldcompilerjava
	$(JAVA_GO) $(ERLANG_EXTRA) src/StartClassen
applet:
	appletviewer startapplet.html

all: comp go

comp:	kon.erl grid.erl grid_test.erl
	$(ERLANG_COMPILER) kon.erl grid.erl grid_test.erl
go:
	erl -sname e_node -setcookie hojjsa -eval 'kon:start()'


doc: docerlang docjava

docerlang: comp $(BEAM_FILES)
	erl -noshell -eval "edoc:files($(EDOC_SRC_LIST), [{dir, 'doc/html'}])" -s init stop
docjava: src/*.java
	javadoc -d doc/javahtml src/*.java
