# Setup Java and Antlr
JC      = javac
JFLAGS  =
ANLTR   = java org.antlr.v4.Tool
GRUN    = java org.antlr.v4.gui.TestRig

# Some key files & Locations
GRAMMAR     = compiler/miserable.g4
PROD_GRAMMAR= production/compiler/miserable.java
COMP_FLDR   = production/compiler/
RETURN      = ../../

PRECOMPILER       = precompiler/precompiler.py
SOURCE_FLDR       = src/
PRECOMPILED_FLDR  = production/precompiled/
PRECOMPILEDS      := $(patsubst src/%.mis,$(PRECOMPILED_FLDR)%,$(wildcard src/*.mis))

PARSER            = miserable
TARGET_FLDR       = target/
TARGETS           := $(patsubst src/%.mis,target/%,$(wildcard src/*.mis))

LEXER             = miserable
TOKENS_FLDR       = production/tokens/
TOKENS            := $(patsubst src/%.mis,$(TOKENS_FLDR)%,$(wildcard src/*.mis))

GRAPH_GRAMMAR     = compiler/miserable_graphing.g4
GRAPH_PARSER      = miserable_graphing
PST_FLDR          = production/psts/
PSTS_PNGS         := $(patsubst src/%.mis,$(PST_FLDR)%.png,$(wildcard src/*.mis))
PSTS_TXTS         := $(patsubst src/%.mis,$(PST_FLDR)%.txt,$(wildcard src/*.mis))

# Make choices
default: all
overwrite: clean default

all: init compiler tokens psts

precompile: $(PRECOMPILEDS)

compiler:   $(COMP_FLDR)*.class

tokens:     $(TOKENS)
psts:       $(PSTS_TXTS) $(PSTS_PNGS)
compile:    $(TARGETS)

init:       $(PROD_GRAMMAR)
	mkdir -p $(TARGET_FLDR)
	mkdir -p $(PRECOMPILED_FLDR)
	mkdir -p $(TOKENS_FLDR)
	mkdir -p $(PST_FLDR)

clean:
	rm -rf production/*
	rm -rf target/*

# file make rules
$(PROD_GRAMMAR):
	$(ANLTR) -o production $(GRAMMAR)
	$(ANLTR) -o production $(GRAPH_GRAMMAR)

# Compiler
$(COMP_FLDR)*.class:
	$(JC) $(JFLAGS) $(COMP_FLDR)*.java -d $(COMP_FLDR)

# Precompilation
$(PRECOMPILED_FLDR)%: $(SOURCE_FLDR)%.mis
	python3 $(PRECOMPILER) $^ $@

# Tokenize
$(TOKENS_FLDR)%: $(PRECOMPILED_FLDR)%
	cd $(COMP_FLDR); $(GRUN) $(LEXER) tokens -tokens $(RETURN)$^ > $(RETURN)$@

# PST Graphing
$(PST_FLDR)%.txt: $(PRECOMPILED_FLDR)%
	cd $(COMP_FLDR); $(GRUN) $(GRAPH_PARSER) prog $(RETURN)$^ > $(RETURN)$@
$(PST_FLDR)%.png: $(PST_FLDR)%.txt
	dot $^ -Tpng -o $@
