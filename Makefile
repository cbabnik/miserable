JC      = javac
JFLAGS  =
ANLTR   = java org.antlr.v4.Tool
GRUN    = java org.antlr.v4.gui.TestRig

GRAMMAR   = compiler/miserable.g4
COMP_FLDR = production/compiler/
RETURN    = ../../

objects := $(patsubst %.mis,../../%,$(wildcard *.c))

LEXER             = miserable
SOURCE_FLDR       = src/
TOKENS_FLDR       = production/tokens/
TOKENS            := $(patsubst src/%.mis,$(TOKENS_FLDR)%,$(wildcard src/*.mis))
PST_FLDR          = production/psts/
PSTS              := $(patsubst src/%.mis,$(PST_FLDR)%,$(wildcard src/*.mis))
TARGET_FLDR       = target/
TARGETS           := $(patsubst src/%.mis,target/%,$(wildcard src/*.mis))

default: all
overwrite: clean default

all: init compiler $(TOKENS)
compiler: $(COMP_FLDR)*.class

init:
	$(ANLTR) -o production $(GRAMMAR)
	mkdir $(TOKENS_FLDR)
	mkdir $(PST_FLDR)

# Compiler
$(COMP_FLDR)*.class:
	$(JC) $(JFLAGS) $(COMP_FLDR)*.java -d $(COMP_FLDR)

# Tokenize
$(TOKENS_FLDR)%: $(SOURCE_FLDR)%.mis
	cd $(COMP_FLDR); $(GRUN) $(LEXER) tokens $(RETURN)$^ > $(RETURN)$@

clean:
	rm -rf production/*
	rm -rf target/*
