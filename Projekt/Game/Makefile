# Tex settings
ERLANG_COMPILER = erlc
JAVA_GO 	= java
JAVA_COMPILER   = javac
ERLANG_EXTRA 	= -classpath .:/usr/lib/erlang/lib/jinterface-1.5.4/priv/OtpErlang.jar

BEAM_FILES	= *.beam
# Clean settings
GEN_EXTENSIONS = *.beam, *.dump



# Remember: $< expands to dependent file
#           $@ expands to target file

clean:
	rm -f $(GEN_EXTENSIONS)
	rm -f cd bin/$(GEN_EXTENSIONS)
	rm -f cd src/$(GEN_EXTENSIONS)
	(cd doc/html && find . -name "*" -a ! -name overview.edoc -exec rm -rf {} \;)

beautify:
	astyle -A7 *.c *.h

oldcompilerjava: 
	$(JAVA_COMPILER) $(ERLANG_EXTRA) EchoServer.java
oldgojava: 
	$(JAVA_GO) $(ERLANG_EXTRA) EchoServer

all: comp go

comp:
	$(ERLANG_COMPILER) kon.erl grid.erl
go:
	erl -sname e_node -setcookie hojjsa -eval 'kon:start()'


doc: $(BEAM_FILES)	
	erl -noshell -eval "edoc:files(*.erl, [{dir, 'doc/html'}])" -s init stop