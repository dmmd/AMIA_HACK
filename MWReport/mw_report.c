#include <stdio.h>
#include <stdlib.h>
#include <libxml/tree.h>
#include <libxml/parser.h>

void checkArgs(int argc, char *argv[]);
static void parse(const char *filename);

int main(int argc, char *argv[]){
	checkArgs(argc, argv);
	LIBXML_TEST_VERSION
	printf("media walk report\n-----------------\n");
	const char *filename = argv[1];
	parse(filename);
	xmlCleanupParser();
	xmlMemoryDump();
	return(0);
}

void checkArgs(int argc, char *argv[]){
	if(argc != 2){
		printf("print the usage warning\n");
		exit(EXIT_FAILURE);
	}

	const char *filename = argv[1];

	FILE *istream;
	if ( (istream = fopen ( filename, "r" ) ) == NULL ){
		printf ( "File %s does not exist\n", filename);
		exit(EXIT_FAILURE);
	}
	else{
		fclose ( istream );
	}
}

static void parse(const char *filename) {
    xmlDocPtr doc;
    doc = xmlReadFile(filename, NULL, 0);
    if(doc == NULL){
    	fprintf(stderr, "FAILED TO PARSE %s\n", filename);c
    }
    xmlFreeDoc(doc);
}
