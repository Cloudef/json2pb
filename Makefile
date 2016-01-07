PREFIX := /usr/local
CPPFLAGS = -std=c++11 -g -fPIC -I.
LDFLAGS = -Wl,-rpath -Wl,.

all: libjson2pb.so json2pb pb2json

clean:
	-rm -f *.o *.so *.a libjson2pb.so.* json2pb pb2json

libjson2pb.so: json2pb.o
	$(CXX) $(LDFLAGS) -o $@ $^ -Wl,-soname=$@ -Wl,-h -Wl,$@ -shared -lcurl -lprotobuf -ljansson

%.o: %.cc
	$(CXX) -o $@ -c $^ $(CPPFLAGS)

json2pb: json2pb_cli.o libjson2pb.so
	$(CXX) -o $@ $^ $(CPPFLAGS) $(LDFLAGS)

pb2json: pb2json_cli.o libjson2pb.so
	$(CXX) -o $@ $^ $(CPPFLAGS) $(LDFLAGS)

install:
	install -D -m 0755 json2pb "$(DESTDIR)$(PREFIX)/bin/json2pb"
	install -D -m 0755 pb2json "$(DESTDIR)$(PREFIX)/bin/pb2json"
	install -D -m 0755 libjson2pb.so "$(DESTDIR)$(PREFIX)/lib/libjson2pb.so"
	install -D -m 0644 json2pb.h "$(DESTDIR)$(PREFIX)/include/json2pb.h"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/bin/json2pb" \
	      "$(DESTDIR)$(PREFIX)/bin/pb2json" \
		  "$(DESTDIR)$(PREFIX)/lib/libjson2pb.so" \
	      "$(DESTDIR)$(PREFIX)/include/json2pb.h"

.PHONY: clean install uninstall
