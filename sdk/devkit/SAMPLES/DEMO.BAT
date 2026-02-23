\bat\setpath
asm tcs
asm prostart
asm gemasm
c demo
asm fardraw
c gembind
c dosbind
asm dosasm
c tcrtl
asm tcrtlasm
asm longasm
asm vdiasm
c vdibind
del demo.prg
link68 [co[demo.inp]]
relmod demo.rel demo.prg
del demo.rel

