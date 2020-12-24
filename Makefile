BASE = calc
BISON = bison
CXX = g++
FLEX = flex
XSLTPROC = xsltproc

all: $(BASE)

%.cc %.hh %.xml %.gv: %.yy
	$(BISON) $(BISONFLAGS) --xml --graph=$*.gv -o $*.cc $<

%.cc: %.ll
	$(FLEX) $(FLEXFLAGS) -o$@ $<

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o$@ $<

$(BASE): main.o driver.o parser.o scanner.o node.o
	$(CXX) -o $@ $^ -lzed

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
