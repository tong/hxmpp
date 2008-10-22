
#include <neko.h>
#include <stdio.h>

// gcc -shared hxmpp_debug.c -o ../ndll/Linux/hxmpp_debug.ndll -I/usr/lin/neko/include


/**
	30 grey
	31 red
	32 blue
	33 yellow
	34 grey
	35 pink
	36 turkis
	37 white
	38 turkis
	39 white
	..
	.. BG
*/
static value printC( value t, value c ) {
	val_check( t, string );
	val_check( c, int );
	int color = val_int(c);
	//printf( "# %s", val_string(t) );
	switch( color ) {
		case 0 : printf( "%c[37;40m%s\n", 27, val_string(t) );break;
		case 1 : printf( "%c[36;40m%s\n", 27, val_string(t) );break;
		case 2 : printf( "%c[35;40m%s\n", 27, val_string(t) );break;
	}
	return alloc_int(0);
}
DEFINE_PRIM( printC, 2 );
