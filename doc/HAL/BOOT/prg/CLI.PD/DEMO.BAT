/* demo batch datei
dir *.bat
pause
/* parameter 0 -  demo.bat copieren
copy demo.bat %0.bat
dir *.bat
pause
/* parameter 1
move %0.bat %1
dir %1.*
pause
/* parameter 2
f1 %2
pause
/* und nun alles entfernen
rm %1
dir
pause
