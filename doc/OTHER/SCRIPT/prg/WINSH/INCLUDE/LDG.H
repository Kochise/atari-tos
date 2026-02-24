/*
 *	Librairies Dynamiques GEM
 *	d‚finitions pour les librairies dynamiques GEM de type LDG 
 * 	Version portable Gnuc/PureC
 *
 *	Copyright 97/98 by Olivier Landemarre and Dominique B‚r‚ziat
 */

#ifndef __LDGAPP__
#define __LDGAPP__

#include <portab.h>

/* Les messages */

#define LDG_REQUEST 	0x4C45  /* demande d'infos … la librairie (client->ldg)*/
#define LDG_TERM       	0x4C47  /* la librairie quitte (ldg->client) */
							    /* le client n'utilise plus la lib (client->ldg) */
#define LDG_GARBAGE    	0x4C48  /* m‚canisme de garbage collector */	
#define LDG_ERROR      	0x4C49  /* erreur de d‚claration */
#define LDG_QUIT       	0x4C4A  /* message interne aux libs */
#define LDG_LIST       	0x4C4B  /* la lib retourne la liste de ses clients */

#define LDG_COOKIE     	0x4C44474DL	/* 'LDGM' */

/* les structures */

/* Le cookie LDG */
typedef struct {
  WORD version;  /* version du cookie, 0x0100 pour le moment */
  char path[128];
  WORD garbage;
  WORD idle;
} LDG_INFOS;

typedef struct entrie{
  char *name;  	/* Nom de la proc‚dure */
  char *info;  	/* infos sur la fonction */
  void *func;  	/* adresse de la fonction */
} PROC;

/* La structure associ‚ au message LDG_ANSWER */

typedef struct ldg {
  LONG magic;	/* doit valoir 'LDGM'   */
  WORD vers;   	/* Version de la librairie */
  WORD id;     	/* id du lanceur 	*/
  WORD num;    	/* nombre d'entr‚es        */
  PROC *list;  	/* les fonctions de la lib */
  char *infos; 	/* infos, description de la lib */
  void *baspag;	/* adresse du module */
  WORD flags;	/* nouveau depuis LDG vers. 0.99 */
  /* Nouveau depuis la version 0.99c */
  void (*close)(void);   
  				 /* Pointeur sur proc‚dure de fermeture du LDG 
  				   (par exemple pour d‚sallouer  la m‚moire) 
  				   	utilisation : void close(void);  */
  LONG RESERVED; /* cette valeur doit rester NULL (r‚serv‚ … 
  					des extensions futures). */
} LDG;

/* valeur du champ 'flags' */
#define LDG_NOT_SHARED	0x1	/* la lib ne peut pas etre partag‚e */
#define LDG_LOCKED		0x2	/* la lib est v‚rrouill‚ */

/* Code erreur */
#define LDG_LIB_FULLED	-1
#define LDG_APP_FULLED	-2
#define LDG_ERR_EXEC	-3
#define LDG_BAD_FORMAT	-4
#define LDG_LIB_LOCKED	-6
#define LDG_NO_MANAGER	-7
#define LDG_NOT_FOUND	-8

/* fonctions pour le client : */
LDG *ldg_exec( int app_id, char *name);
void ldg_term( int app_id, LDG *ldg);
int  ldg_error( void);
void *ldg_find( char *name, LDG *ldg);

/* fonctions pour le serveur : */
int  ldg_init( LDG *ldg);

/* divers */
int ldg_cookie( long, long *);
void ldg_debug( char *, ...);
void *ldg_Malloc(long size);
void *ldg_Calloc(long count,long size);
int ldg_Free(void *memory);

/* Version de la librarie */
extern char ldg_version[];

#endif __LDGAPP__
