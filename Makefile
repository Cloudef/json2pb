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
