#include <libgen.h>
#include <unistd.h>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <sys/stat.h>
#include <sys/types.h>

static std::string remove_ext(const std::string &fname)
{
    const auto d = fname.find_last_of(".");
    return (d == std::string::npos ? fname : fname.substr(0, d));
}

int main(int argc, char *argv[])
{
        if (argc < 4) {
                std::cerr << "usage: " << std::string(basename(argv[0])) << " MESSAGE PROTO PROTOBUF" << std::endl;
                return EXIT_FAILURE;
        }

	std::string msg(argv[1]);
	std::string proto(argv[2]);
	std::string blob(argv[3]);

	std::string code = R"(
	#include <json2pb.h>
	#include <cstdlib>
	#include <fstream>
	#include <sstream>
	#include <string>
	#include <iostream>
	#include ")" + remove_ext(proto) + ".pb.h" + R"("

	int main(void) {
	    std::ifstream fle(")" + blob + R"(");
	    if (!fle.is_open()) {
		    std::cerr << "could not open file: " << ")" + blob + R"(" << std::endl;
		    return EXIT_FAILURE;
	    }

	    std::stringstream buffer;
	    buffer << fle.rdbuf();
	    fle.close();

	    )" + msg + " msg;" + R"(
	    msg.ParseFromString(buffer.str());
	    std::cout << pb2json(msg) << std::endl;
	    return EXIT_SUCCESS;
	}
	)";

        char c[] = "/tmp/pb2json-XXXXXX";
	if (!mkdtemp(c)) {
	    std::cerr << "failed to mkdtemp" << std::endl;
	    return EXIT_FAILURE;
	}

	std::string tmp(c);
	auto src = tmp + "/" + remove_ext(proto) + ".pb.cc";
	auto hdr = tmp + "/" + remove_ext(proto) + ".pb.h";
	auto parser = tmp + "/parser.cc";
	auto binary = tmp + "/bin";
	mkdir(tmp.c_str(), 0755);

	std::ofstream out(parser);
	out << code;
	out.close();

	system(std::string("protoc --cpp_out=" + tmp + " " + proto).c_str());
        system(std::string("c++ -std=c++11 -I. " + parser + " " + src + " -o " + binary + " -lprotobuf -Wl,-rpath,. -L. -ljson2pb").c_str());
	remove(parser.c_str());
	remove(src.c_str());
	remove(hdr.c_str());
	system(binary.c_str());
	remove(binary.c_str());
	remove(tmp.c_str());
        return EXIT_SUCCESS;
}
