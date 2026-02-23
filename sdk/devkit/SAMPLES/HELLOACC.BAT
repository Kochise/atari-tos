\bat\setpath
asm tcsacc
asm accstart
asm gemasm
copy deskacc1.h deskacc.h
c hello
c tgembind
asm tcrtlasm
asm longasm
asm vdiasm
c vdibind
del hello.acc
link68 [co[helloacc.inp]]
relmod helloacc.rel hello.acc
del helloacc.rel
