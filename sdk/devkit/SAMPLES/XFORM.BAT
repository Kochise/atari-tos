\bat\setpath
asm tcs
asm prostart
asm gemasm
c xform
c xlib
c gembind
asm longasm
c tcrtl
asm tcrtlasm
asm crmuldiv
asm vdiasm
c vdibind
del xform.prg
link68 [co[xform.inp]]
relmod xform.rel xform.prg
del xform.rel
