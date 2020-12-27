BASE = calc
BISON = bison
CC = g++
FLEX = flex
XSLTPROC = xsltproc

STD = c++11
CFLAGS = -std=$(STD) \
	-W -Wall -Wextra -pedantic -fexceptions \
	-fdata-sections -ffunction-sections
LFLAGS = -lzed -Wl,--gc-sections

all: $(BASE)

%.cc %.hh %.xml %.gv: %.yy
	$(BISON) $(BISONFLAGS) --xml --graph=$*.gv -o $*.cc $<

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o$@ $<

%.o: %.cc
	$(CC) $(CFLAGS) -c -o$@ $<

$(BASE): main.o driver.o parser.o scanner.o node.o
	$(CC) -o $@ $^ $(LFLAGS)

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
