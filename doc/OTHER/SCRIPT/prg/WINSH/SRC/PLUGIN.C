/*
 * Plugin pour WINSH
 * On met au point le protocol
 */

#include <stdio.h>
#include <winsh\plugin.h>

struct var ret;

MODULE3(hello) {
	int i;
	
	printf( "Hello: %ld argument%s\n", narg, narg?"s":"");
	for( i=0; i<narg; i++) {
		switch( pile[i]->type) {
		case INTEGER:
			printf( "arg %d: %d (INTEGER)\n", i, pile[i]->val.integer);
			break;
		case PTR:
			printf( "arg %d: 0x%lx (PTR)\n", i, pile[i]->val.ptr);
			break;
		case STRING:
			printf( "arg %d: %s (STRING)\n", i, pile[i]->val.string);
			break;
		case REAL:
			printf( "arg %d: %f (REAL)\n", i, pile[i]->val.real);
			break;
		}
	}
	return (VAR)NULL;
}

MODULE(version)
{

	static char ptr[] = "Hello ma poule";
	
	R_STR = ptr;
	return &ret;
}

PROC Func[] = { "hello", "%v", hello,
				"version", "", version };

LDG  Ldg[] = { 'LDGM', 0x0100, 0, 2,
			 	Func, "Plugin WinSH",
				NULL, 0,	/* Flags */
				NULL, 0L};


int main( void)
{
	ldg_init( Ldg);
	return 0;
}
