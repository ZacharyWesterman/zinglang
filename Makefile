BASE = calc
BISON = bison
CC = g++
FLEX = flex
XSLTPROC = xsltproc

STD = c++17
CCFLAGS = -std=$(STD) \
	-W -Wall -Wextra -pedantic -fexceptions -Wno-psabi \
	-fdata-sections -ffunction-sections

all: $(BASE)

%.cc %.hh %.xml %.gv: %.yy
	$(BISON) $(BISONFLAGS) --xml --graph=$*.gv -o $*.cc $<

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o$@ $<

%.o: %.cc
	$(CC) $(CCFLAGS) $(CFLAGS) -c -o$@ $<

$(BASE): main.o driver.o parser.o scanner.o node.o
	$(CC) -o $@ $^ $(LFLAGS) -lzed -Wl,--gc-sections

main.o: parser.hh
parser.o: parser.hh
scanner.o: parser.hh
driver.o: parser.hh

html: parser.html
%.html: %.xml
	$(XSLTPROC) $(XSLTPROCFLAGS) -o $@ $$($(BISON) --print-datadir)/xslt/xml2xhtml.xsl $<

CLEANFILES = $(BASE) *.o parser.hh parser.cc parser.output parser.xml parser.html parser.gv location.hh	scanner.cc

clean:
	rm -f $(CLEANFILES)
