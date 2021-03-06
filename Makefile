#/*
# * Copyright (c) 2012, TU Delft, TU Eindhoven and TU Kaiserslautern 
# * All rights reserved. 
# * 
# * Redistribution and use in source and binary forms, with or without 
# * modification, are permitted provided that the following conditions are 
# * met: 
# *
# * 1. Redistributions of source code must retain the above copyright 
# * notice, this list of conditions and the following disclaimer. 
# *
# * 2. Redistributions in binary form must reproduce the above copyright 
# * notice, this list of conditions and the following disclaimer in the 
# * documentation and/or other materials provided with the distribution. 
# *
# * 3. Neither the name of the copyright holder nor the names of its 
# * contributors may be used to endorse or promote products derived from 
# * this software without specific prior written permission. 
# *
# * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS 
# * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
# * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
# * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
# * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
# * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
# * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
# * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
# * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
# * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
# * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
# *
# * Authors: Karthik Chandrasekar
# *
# */


# Name of the generated binary.
BINARY := drampower
LIBS := src/libdrampower.a src/libdrampowerxml.a

# Identifies the source files and derives name of object files.
CORESOURCES := PowerCalc.cc $(wildcard src/*.cc)
XMLPARSERSOURCES := $(wildcard src/xmlparser/*.cc)
LIBSOURCES := $(wildcard src/libdrampower/*.cc)
ALLSOURCES := ${CORESOURCES} ${XMLPARSERSOURCES} ${LIBSOURCES}

COREOBJECTS := ${CORESOURCES:.cc=.o}
XMLPARSEROBJECTS := ${XMLPARSERSOURCES:.cc=.o}
LIBOBJECTS := ${LIBSOURCES:.cc=.o}
ALLOBJECTS := ${ALLSOURCES:.cc=.o}

DEPENDENCIES := ${ALLSOURCES:.cc=.d}

##########################################
# Compiler settings
##########################################

# State what compiler we use.
CXX := g++

# Optimization flags. Usually you should not optimize until you have finished
# debugging, except when you want to detect dead code.
OPTCXXFLAGS =

# Debugging flags.
DBGCXXFLAGS = -g

# Common warning flags shared by both C and C++.
WARNFLAGS := -W -Wall -pedantic-errors -Wextra -Werror \
             -Wformat -Wformat-nonliteral -Wpointer-arith \
             -Wcast-align -Wconversion

# Sum up the flags.
CXXFLAGS := -O #${WARNFLAGS} ${DBGCXXFLAGS} ${OPTCXXFLAGS}

# Linker flags.
LDFLAGS := -Wall

##########################################
# Xerces settings
##########################################

XERCES_ROOT ?= /usr
XERCES_INC := $(XERCES_ROOT)/include
XERCES_LIB := $(XERCES_ROOT)/lib
XERCES_LDFLAGS := -L$(XERCES_LIB) -lxerces-c

##########################################
# Targets
##########################################

$(BINARY): ${XMLPARSEROBJECTS} ${COREOBJECTS}
	$(CXX) $(LDFLAGS) -o $@ $^ $(XERCES_LDFLAGS)

# From .cpp to .o. Dependency files are generated here
%.o: %.cc
	$(CXX) ${CXXFLAGS} -MMD -MF $(subst .o,.d,$@) -iquote src -o $@ -c $<

all: ${BINARY}

lib: ${COREOBJECTS} ${LIBOBJECTS}
	ar -cvr src/libdrampower.a ${COREOBJECTS} ${LIBOBJECTS}

parserlib: ${XMLPARSEROBJECTS}
	ar -cvr src/libdrampowerxml.a ${XMLPARSEROBJECTS}

clean:
	$(RM) $(ALLOBJECTS) $(DEPENDENCIES) $(BINARY) $(LIBS)

.PHONY: clean

-include $(DEPENDENCIES)
