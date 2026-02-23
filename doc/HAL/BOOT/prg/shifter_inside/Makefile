
#TARGETS=timing.mfm.xz
PROGS=shin_st.prg shin_ste.prg

AS=vasmm68k_mot
ASOPT=-m68000 -Ftos -tos-flags=7 -nosym

all: $(TARGETS) $(PROGS)

clean:
	rm -f $(TARGETS) $(PROGS) *.o

%.st: %.prg
	dd if=/dev/zero of=$@ count=720
	mformat -i $@ -a -t 80 -h 1
	mmd -i $@ ::auto
	mcopy -i $@ $^ ::auto

%.msa: %.st
	rm -f $@
	hmsa $^

%.xz: %
	xz -f9 $<

shin_st.prg: shin.s
	$(AS) $(ASOPT) $< -o $@

shin_ste.prg: shin.s
	$(AS) $(ASOPT) -DSTE $< -o $@
