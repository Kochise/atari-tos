/* TEXT.C
 * ================================================================
 * DATE: December 12, 1990
 * DESCRIPTION: Text for the FSM installation program.
 */
#include "country.h"


/* FILE.C
 * ================================================================
 */
#if USA|UK
char alert1[] = "[3][INSTALL.DAT is missing.|The file must be in the same|directory as INSTALL.PRG. |The installation has been|cancelled.][ Exit ]";
char alert2[] = "[3][ | There is not enough memory| to continue. Installation| has been Cancelled ][ OK ]";
char tosalert[] = "[1][|Warning: The Bezier routines|will not work properly with |TOS Version 3.01. Please update|your OS to a newer version.][ OK ]";
char arsc[] = "[3][ | Can't load resource file. ][ OK ]";
#endif

#if FRENCH
char alert1[] = "[3][INSTALL.DAT est manquant.|Le fichier doit Çtre dans|le mÇme repertoire qu 'INSTALL.PRG.| |L'Installation est annulÇc.][ Quitter ]";
char alert2[] = "[3][ll n'y a pas assez de mÇmoire|pour continuer.| |l'Installation a ÇtÇ annulÇe.][ CONFIRMER ]";
char tosalert[] = "[1][Attention: Les routines de|Bezier ne peuvent pas|fonctionner sur le TOS 3.01.][ CONFIRMER ]";
char arsc[] = "[3][|Chargement du fichier|ressource impossible.][ CONFIRMER ]";
#endif
/*
 * These string translations have been corrected
 * 2-Mar-1993, nbk, ATARI Computer GmbH
 */
#if GERMAN
char alert1[] = "[3][Datei INSTALL.DAT nicht|gefunden. Diese Datei muû im|selben Verzeichnis wie|INSTALL.PRG liegen. Die|Installation wurde abgebrochen.][ Abbruch ]";
char alert2[] = "[3][ | Zu wenig Speicher frei um| fortzufahren. Die Installation| wird abgebrochen.][ Abbruch ]";
char tosalert[] = "[1][Warnung: Die Bezierroutinen|kînnen mit TOS 3.01 nicht|korrekt arbeiten. Bitte rÅsten Sie|Ihren Rechner auf eine neuere|Betriebssystem-Version um.][ Abbruch ]";
char arsc[] = "[3][ |Kann die MenÅbaum-Datei (*.RSC)|nicht laden.][ Abbruch ]";
#endif


/* INSTALL.C
 * ================================================================
 */
#if USA|UK
char inserta[] = "Please insert %s into";
char insertb[] = "Drive %c and press RETURN.";
#endif

#if FRENCH
char inserta[] = "InsÇrez la disquette %s dans";
char insertb[] = "le lecteur %c et appuyez sur RETURN.";
#endif

#if GERMAN
char inserta[] = "Bitte %s in Laufwerk";
char insertb[] = "%c einlegen und RETURN drÅcken.";
#endif



/* MAINSTUF.C
 * ================================================================
 */
#if USA|UK
char alert11[] = "[3][ | No Hard Disk Installed.  | Installation Cancelled.  ][  OK  ]";

char no_cpxfile[] = "[1][ | The CONTROL.INF file does not | exist. The CPXs cannot be | installed.][ OK ]";
char no_cpxpath[] = "[1][ | The CONTROL.INF path is | invalid. The CPXs cannot| be installed.][ OK ]";
char wfsm[]   = " Atari SpeedoGDOS Installation ";
char wfont[]  = " Atari FONT GDOS Installation ";
char wtitle[] = " Atari Font Installation ";

char nowin[] = "[1][ | There are no more windows.| Please close a window and| run Install again.][ OK ]";
char aexit[] = "[2][ | The installation is not yet | complete. Are you sure you | want to exit Install? ][ Yes | NO ]";
char anone[] = "None Selected";

char bad_path[] = "[1][ |The directory that you typed|is invalid. Please type in a|complete path.][ OK ]";
char dirmake[] = "[1][ | The directory that you typed | does not exist. Do you want | to create the directory?][ OK | No ]";
char bad_drive[] = "[1][ |The Drive you typed is invalid.|The drive must be an active |partition between C:\\ and P:\\.][ OK ]";

char read_error[]   = "[1][ | An error has occurred | while reading the file.][RETRY|Skip|Quit]";
char write_error[]  = "[1][ | An error has occurred | while writing to the | file. ][RETRY|Skip|Quit]";
char mem_error[]    = "[1][ | There is not enough memory | to transfer this file.][RETRY|Skip|Quit]";
char open_error[]   = "[1][ | An error has occurred | while opening this file.][RETRY|Skip|Quit]";
char no_file_error[]= "[1][ |  File not found! ][RETRY|Skip|Quit]";
#endif

#if FRENCH
char alert11[] = "[3][ | Pas de disque dur installÇ.  | | Installation annulÇe.  ][  CONFIRMER  ]";

char no_cpxfile[] = "[1][ | The CONTROL.INF file does not | exist. The CPXs cannot be | installed.][ OK ]";
char no_cpxpath[] = "[1][ | The CONTROL.INF path is | invalid. The CPXs cannot| be installed.][ OK ]";
char wfsm[]   = " Installation d'Atari SpeedoGDOS";
char wfont[]  = " Installation d'Atari FontGDOS";
char wtitle[] = " Atari Font Installation ";

char nowin[] = "[1][ |II n'y a plus de fenàtre|disponible. Fermez-en une|devenue inutile et relancez|I'Installation.][ CONFIRMER ]";
char aexit[] = "[2][ |L'installation n'est pas|terminÇe. Etes-vous sñr de|vouloir quitter le programme? ][ Oui | NON ]";
char anone[] = "Pas de sÇlection";

char bad_path[] = "[1][ |Le rÇpertoire saisi n'est pas|valide. Veuillez ressaisir|le chemin complet.][ CONFIRMER ]";
char dirmake[] = "[1][ |Le rÇpertoire saisi n'existe |pas. Voulez-vous le crÇer? ][ CONFIMER | NON ]";
char bad_drive[] = "[1][ |Le lecteur choisi n'existe pas. |II doit correspondre Ö une |partition active entre|C:\\ et P:\\.][ CONFIRMER ]";

char read_error[]  = "[1][ |Une erreur s'est produite|durant la lecture du fichier. ][RêSSAYER|Suivant|Quitter]";
char write_error[]   = "[1][ |Une erreur s'est produite|lors de l'Çcriture du fichier.][RêSSAYER|Suivant|Quitter]";
char mem_error[]    = "[1][ |ll n'y a pas assez de mÇmoire|pour transfÇrer ce fichier.][RêSSAYER|Suivant|Quitter]";
char open_error[]   = "[1][ |Une erreur s'est produite|durant l'ouverture du fichier.][RêSSAYER|Suivant|Quitter]";
char no_file_error[]= "[1][ |Fichier non trouvÇ! ][RêSSAYER|Suivant|Quitter]";
#endif

#if GERMAN
char alert11[] = "[3][ | Keine Festplatte angemeldet.|Die Installation wurde abgebrochen.][  Abbruch  ]";

char no_cpxfile[] = "[1][ | Die Datei CONTROL.INF existiert | nicht. Die CPX-Module kînnen | nicht installiert werden.][ OK ]";
char no_cpxpath[] = "[1][ | Der Pfad fÅr CONTROL.INF ist | ungÅltig. Die CPX-Module kînnen | nicht installiert werden.][ OK ]";
char wfsm[]   = " Atari SpeedoGDOS Installation ";
char wfont[]  = " Atari FONT GDOS Installation ";
char wtitle[] = " Atari Font Installation ";

char nowin[] = "[1][ Der GEM Desktop hat keine| Fenster mehr. Bitte schlieûen| Sie ein unbenutztes Fenster| und rufen Sie INSTALL noch | einmal auf.][ OK ]";
char aexit[] = "[2][ Die Installation ist noch| nicht vollstÑndig durchgefÅhrt.| Wollen Sie das Installations-|programm wirklich verlassen?][ Ja | Nein ]";
char anone[] = "Nichts ausgewÑhlt";

char bad_path[] = "[1][Das von Ihnen eingegebene|Verzeichnis ist ungÅltig. |Bitte geben Sie einen |kompletten Pfad ein.][ OK ]";
char dirmake[] =  "[1][Das von Ihnen eingegebene|Verzeichnis existiert nicht.|Wollen Sie es anlegen?][ OK | Nein ]";
char bad_drive[] ="[1][Das von Ihnen angegebene|Laufwerk ist ungÅltig. |Das Laufwerk muû eine |aktive Partition zwischen |C:\\ und P:\\ sein.][ OK ]";

char read_error[]   = "[1][ | Beim Lesen der Datei ist ein| Fehler aufgetreten.][Nochmal|öbergehen|Abbruch]";
char write_error[]  = "[1][ | Beim Schreiben der Datei ist| ein Fehler aufgetreten. ][Nochmal|öbergehen|Abbruch]";
char mem_error[]    = "[1][ | Zuwenig Speicher um diese| Datei zu Åbertragen.][Nochmal|öbergehen|Abbruch]";
char open_error[]   = "[1][ | Ein Fehler ist beim ôffnen der| Datei aufgetreten.][Nochmal|öbergehen|Abbruch]";
char no_file_error[]= "[1][ | Datei nicht gefunden! ][Nochmal|öbergehen|Abbruch]";
#endif


/* GEMSKEL.C
 * ================================================================
 */
#if USA|UK
char alow[] = "[3][The install program needs an|80 column screen to display|its dialog boxes. Please|re-boot in a higher resolution.][ Sorry ]";
#endif

#if FRENCH
char alow[] = "[3][Le programme d'installation|nÇcessite un affichage 80|colonnes. Relancez l'ordinateur dans|une rÇsolution plus ÇlevÇ.][ DÇsolÇ ]";
#endif

#if GERMAN
char alow[] = "[3][Das INSTALL-Programm|braucht eine 80-spaltige|Bilddarstellung um|seine Dialoge anzuzeigen.][ Schade ]";
#endif


/* DPATH/EPATH.C */
#if USA
char nospace[] = "[1][ There is not enough room on | this drive. Try another | drive or make some room on | this one.][ OK ]";
#endif

#if GERMAN
char nospace[] = "[1][ Auf diesem Laufwerk ist nicht | genug Speicherplatz frei. | Versuchen Sie es mit einem | anderen oder schaffen Sie Platz | auf diesem Laufwerk.][ OK ]";
#endif

#if FRENCH
char nospace[] = "[1][ There is not enough room on | this drive. Try another | drive or make some room on | this one.][ OK ]";
#endif

