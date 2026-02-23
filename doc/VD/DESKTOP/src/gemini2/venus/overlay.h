/*
 * @(#) Gemini\overlay.h
 * @(#) Stefan Eissing, 27. Febuar 1993
 *
 * description: functions to start overlays
 */

#ifndef G_OVERLAY__
#define G_OVERLAY__

/* setzt die internen Variablen, um sp„ter doOverlay auszufhren
 */
void setOverlay(char *fname, char *command, word gemstart);

/* Falls vorher setOverlay ausgefhrt wurde, so wird die Ausfhrung
 * eines Programms als Overlay bei Programmende vorbereitet.
 * Ist dies nicht geschehen, so liefert die Funtkion FALSE zurck.
 */
word doOverlay (int *its_an_overlay);

#endif /* !G_OVERLAY */