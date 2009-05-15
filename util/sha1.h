
#ifndef SHA1_H
#define SHA1_H

#define SHA1_SIZE 20

typedef unsigned char SHA1_DIGEST[SHA1_SIZE];

typedef struct {
	unsigned long state[5];
	unsigned long count[2];
	unsigned char buffer[64];
} SHA1_CTX;

void sha1_init( SHA1_CTX *c );
void sha1_update( SHA1_CTX *c, const unsigned char *data, unsigned int len );
void sha1_final( SHA1_CTX *c, SHA1_DIGEST digest );

#endif
