/*
 *	Code erreur retourn‚ par WinSh
 */


#define ERROR_FILE	-33		/* EFILNF */
#define ERROR_MACRO	-111	/* mauvaise ‚valuation d'une variable */
#define ERROR_LDG	-112	/* erreur module  LDG */
#define ERROR_FI	-113	/* fi/else non trouv‚e */
#define ERROR_PEXEC	-114	/* erreur PEXEC */
#define ERROR_IF	-115	/* if mal format‚ */
#define ERROR_CMD	-116	/* fonctions inconnue */
#define ERROR_PAR	-117	/* Mauvais paramŠtrage d'une fonction */
#define ERROR_VAR	-118	/* Variable non d‚finie */
#define ERROR_OBJ	-119	/* l'objet n'existe pas */
#define ERROR_SYN	-120	/* erreur de syntaxe avec $ */
#define ERROR_FLD	-121	/* champs objet inconnu */
#define ERROR_CRASH -122	/* WinSH a plant‚ */
#define ERROR_QUOTE	-123	/* erreur constante ascii */
#define ERROR_EXPR	-124	/* erreur dans polish */
char *error( int err);