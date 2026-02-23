\bat\setpath
asm tcs
c dosbind
asm dosasm
c tcrtl
asm tcrtlasm
asm longasm
c rscreate
del rscreate.prg
link68 [co[rscreate.inp]]
relmod rscreate.rel rscreate.prg
del rscreate.rel
rscreate.prg
