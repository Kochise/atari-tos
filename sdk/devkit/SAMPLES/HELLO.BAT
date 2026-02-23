\bat\setpath
asm tcs
asm prostart
asm gemasm
copy deskacc0.h deskacc.h
c hello
c tgembind
asm tcrtlasm
asm longasm
asm vdiasm
c vdibind
del hello.prg
link68 [co[hello.inp]]
relmod hello.rel hello.prg
del hello.rel
