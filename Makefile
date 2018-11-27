NAME = zasm

SRCS = $(wildcard *.cpp)
OBJS = $(patsubst %.cpp,%.o,$(SRCS))

ARCH = $(shell g++ -dumpmachine)

ifeq ($(findstring x86_64,$(ARCH)),x86_64)
CCTARGET = -m64
else
ifeq ($(findstring i686,$(ARCH)),i686)
CCTARGET = -m32
else
CCTARGET =
endif
endif

INCLUDE = -I"../libzed" -I"../zing"
CFLAGS = $(INCLUDE) -std=c++11 -W -Wall -Wextra -pedantic -fexceptions
LFLAGS = -shared -lzed -Wl,--no-undefined

# opt defaults to -O3
ifndef OPT
OLEVEL = 3
endif

#if opt flag is true
ifneq (,$(findstring $(OPT),S size Size SIZE))
OLEVEL = s
endif

# if debug flag is false
ifeq (,$(findstring $(DEBUG),1 true True TRUE))
CFLAGS += -O$(OLEVEL) -g0
else
CFLAGS += -g3 -O$(OLEVEL) -DDEBUG
endif

ifeq ($(OS),Windows_NT)
LFLAGS += -L.
SONAME = $(NAME).exe
RMOBJS = $(subst /,\,$(OBJS))
RM = del
else
SONAME = $(NAME).so
RMOBJS = $(OBJS)
RM = rm -f
endif

CC = g++
LN = g++

default: $(SONAME)

$(SONAME): $(OBJS)
	$(LN) $(LFLAGS) -o $@ $^

lang.o: lang.cpp
	$(CC) $(CFLAGS) -fPIC -o $@ -c $^

%.o: %.cpp %.h
	$(CC) $(CFLAGS) -fPIC -o $@ -c $<

clean:
	rm -f *.o *.so

.PHONY: default clean
