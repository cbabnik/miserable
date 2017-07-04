JC      = javac
JFLAGS  =
ANLTR   = java org.antlr.v4.Tool
GRUN    = java org.antlr.v4.gui.TestRig

GRAMMAR     = compiler/miserable.g4
PROD_GRAMMAR= production/compiler/miserable.java
PRECOMPILER = precompiler/precompiler.py
COMP_FLDR   = production/compiler/
RETURN      = ../../

objects := $(patsubst %.mis,../../%,$(wildcard *.c))

LEXER             = miserable
SOURCE_FLDR       = src/
PRECOMPILED_FLDR  = production/precompiled/
PRECOMPILEDS      := $(patsubst src/%.mis,$(PRECOMPILED_FLDR)%,$(wildcard src/*.mis))
TOKENS_FLDR       = production/tokens/
TOKENS            := $(patsubst src/%.mis,$(TOKENS_FLDR)%,$(wildcard src/*.mis))
PST_FLDR          = production/psts/
PSTS              := $(patsubst src/%.mis,$(PST_FLDR)%,$(wildcard src/*.mis))
TARGET_FLDR       = target/
TARGETS           := $(patsubst src/%.mis,target/%,$(wildcard src/*.mis))

default: all
overwrite: clean default

all: init tokens

precompile: $(PRECOMPILEDS)

init:       $(PROD_GRAMMAR)
compiler:   $(COMP_FLDR)*.class

tokens:     precompile compiler $(TOKENS)
psts:       compiler $(PSTS)
compile:    compiler $(TARGETS)


$(PROD_GRAMMAR):
	$(ANLTR) -o production $(GRAMMAR)
	mkdir -p $(TARGET_FLDR)
	mkdir -p $(PRECOMPILED_FLDR)
	mkdir -p $(TOKENS_FLDR)
	mkdir -p $(PST_FLDR)

# Compiler
$(COMP_FLDR)*.class:
	$(JC) $(JFLAGS) $(COMP_FLDR)*.java -d $(COMP_FLDR)

# Precompilation
$(PRECOMPILED_FLDR)%: $(SOURCE_FLDR)%.mis
	python3 $(PRECOMPILER) $^ $@
# Tokenize
$(TOKENS_FLDR)%: $(PRECOMPILED_FLDR)%
	cd $(COMP_FLDR); $(GRUN) $(LEXER) tokens -tokens $(RETURN)$^ > $(RETURN)$@

clean:
	rm -rf production/*
	rm -rf target/*
