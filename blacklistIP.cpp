#include <iostream>		//std::cout, std::cin, etc...
#include <string>		//std::string
#include <getopt.h>		//int getopt_long()
#include <stdexcept>	//std::exception, std::invalid_argument etc...

//blacklistIP global variables
/* todo: set vars from external config file */
const std::string workDir = "/etc/blacklistIP/";
const std::string saveFile = workDir + "blacklistIP_save";
const std::string sortFile = workDir + "blacklistIP_sort";
const std::string compFile = workDir + "blacklistIP_comp";
const std::string usage ="Usage: blacklistIP <OPTION> [ARGUMENT]\n\
User-friendly front-end to dropping all inbound packets from specified IPs using iptables\n\
\n\
  <OPTION>       [ARGUMENT]      DESCRIPTION\n\
  -a --add        IP[,IP[,...]]  Drop/Block incoming packets from IP(s)\n\
  -c --compare    --NONE--       Compare the current BLACKLIST chain to the saved one\n\
  -d --load       --NONE--       Initializes the iptables and loads the IPs to block from\n\
                                     " + saveFile + " (only useful after a reboot)\n\
  -h --help       --NONE--       Prints help & usage information (this message)\n\
  -l --list       --NONE--       Prints list of blocked IPs in chain\n\
  -i --import     --NONE--       Adds any IPs in " + saveFile + " that are not currently in the chain\n\
  -o --overwrite  --NONE--       Clears all IPs from the chain and loads all IPs in $blIP_saveFile\n\
  -r --remove     IP             Removes IP from chain\n\
  -s --sort       --NONE--       Sort the IPs in the chain\n\
  -w --write      --NONE--       Saves the IPs in the chain to " + saveFile;

int main(int argc, char* argv[]) {
	try {
		if (argc < 2) {
			std::cout << usage << std::endl;
			return 0;
		} else {
			// Vars for getopt.h
			extern char *optarg;
			extern int optind, opterr, optopt;
			const char *shortOpts="a:cdhlior:sw";
			int option_index = 0;
			//struct option { const char *name; int has_args; int *flag; int val; };
			const struct option long_options[] = {
				{"add",			required_argument,	0,	'a'},
				{"compare",		no_argument,		0,	'c'},
				{"load",		no_argument,		0,	'd'},
				{"help",		no_argument,		0,	'h'},
				{"list",		no_argument,		0,	'l'},
				{"import",		no_argument,		0,	'i'},
				{"overwrite",	no_argument,		0,	'o'},
				{"remove",		required_argument,	0,	'r'},
				{"sort",		no_argument,		0,	's'},
				{"write",		no_argument,		0,	'w'},
				{0, 0, 0, 0}
			};

			int opt = 0;
			/* int getopt_long(int argc, char * const argv[],
				const char *optstring,
				const struct option *longopts, int *longindex);
			*/
			while ((opt = getopt_long(argc, argv, shortOpts, long_options, &option_index)) != -1) {
				switch (opt) {
					case 'a': //ADD
						std::cout << "A " << optarg << std::endl;
						break;

					case 'c': //COMPARE
						break;

					case 'd': //LOAD
						break;

					case 'h': //HELP
						std::cout << usage << std::endl;
						break;

					case 'l': //LIST
						break;

					case 'i': //IMPORT
						break;

					case 'o': //OVERWRITE
						break;

					case 'r': //REMOVE
						std::cout << "R " << optarg << std::endl;
						break;

					case 's': //SORT
						break;

					case 'w': //WRITE
						break;

					default:
						throw std::invalid_argument("Invalid Option");
				};
			};
			return 0;
		};
	}
	catch (const std::exception &e) {
		//std::cerr << e.what() << std::endl;
		std::cerr << "Try '" << argv[0] << " --help' for more information." << std::endl;
		return 1;
	}
	catch (const std::string &e) {
		std::cerr << "ERROR: " << e << std::endl;
		std::cerr << usage << std::endl;
		return 1;
	}
	catch (...) {
		std::cerr << "Unhandled exception!\nWaiting for user input before exiting..." << std::endl;
		std::cin.get();
		return -1;
	}

	return -1;
}