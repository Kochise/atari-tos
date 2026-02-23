typedef struct
{
	long date;

	short *dcolor_a;
	short *dcolor_b;

	short *currxywh;
	short *kind;
	short *owner;
	char **name;
	char **info;

	unsigned char *menu_id;
	OBJECT **menu_tree;
	short *flags;
} A_MAN;

