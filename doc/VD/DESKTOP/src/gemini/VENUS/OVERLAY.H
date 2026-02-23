/*
 * overlay.h
 *
 * project: venus
 *
 * author: stefan eissing
 *
 * description: functions to start overlays
 *
 * last change: 25.06.1990
 */

/* setzt die internen Variablen, um sp„ter doOverlay auszufhren
 */
void setOverlay(char *fname, char *command, word gemstart);

/* Falls vorher setOverlay ausgefhrt wurde, so wird die Ausfhrung
 * eines Programms als Overlay bei Programmende vorbereitet.
 * Dabei wird der Status von Venus in <tmpinfo> gespeichert.
 * Ist dies nicht geschehen, so liefert die Funtkion FALSE zurck.
 */
word doOverlay(const char *tmpinfo);