# Tex settings
JAVA_GO 	= java
JAVA_COMPILER   = javac
ERLANG_EXTRA 	= -classpath .:/usr/lib/erlang/lib/jinterface-1.5.4/priv/OtpErlang.jar

# Clean settings
GEN_EXTENSIONS = *.class



# Remember: $< expands to dependent file
#           $@ expands to target file

clean:
	rm -f $(GEN_EXTENSIONS) 

beautify:
	astyle -A7 *.c *.h

comp: 
	$(JAVA_COMPILER) $(ERLANG_EXTRA) EchoServer.java
go: 
	$(JAVA_GO) $(ERLANG_EXTRA) EchoServer
all: comp go
