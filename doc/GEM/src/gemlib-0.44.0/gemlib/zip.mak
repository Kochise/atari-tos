#
# $Id: zip.mak,v 1.4 2005/04/01 18:11:20 a_bercegeay Exp $
#

# makefile for gemlib distrib

# note:
# $Id: zip.mak,v 1.4 2005/04/01 18:11:20 a_bercegeay Exp $

include files.mak
include VERSION

.PHONY: purec sozobonx gcc281 gcc doc src

default: purec sozobonx gcc281 gcc doc src

purec:
	rm -rf $@ gemlib-$(VERSION)-$@.zip
	mkdir $@ $@/lib $@/include
	cp $(FILES_INC) include/purec/compiler.h $@/include
	cp $(LIB_PUREC) $@/lib
	zip -r gemlib-$(VERSION)-$@.zip $@
	rm -rf $@

sozobonx:
	rm -rf $@ gemlib-$(VERSION)-$@.zip
	mkdir $@ $@/lib $@/include
	cp $(FILES_INC) include/sozobon/compiler.h $@/include
	cp $(LIB_SOZOBON) $@/lib
	zip -r gemlib-$(VERSION)-$@.zip $@
	rm -rf $@

gcc281:
	rm -rf $@ gemlib-$(VERSION)-$@.zip
	mkdir $@ $@/lib $@/include
	cp $(FILES_INC) include/gcc281/compiler.h $@/include
	cp $(LIB_GCC281_MSHORT) $(LIB_GCC281) $@/lib
	zip -r gemlib-$(VERSION)-$@.zip $@
	rm -rf $@

gcc:
	rm -rf $@ gemlib-$(VERSION)-$@.zip
	mkdir $@ $@/lib $@/include
	cp $(FILES_INC) $@/include
	cp $(LIB_GCC) $(LIB_GCC_MSHORT) $@/lib
	zip -r gemlib-$(VERSION)-$@.zip $@
	rm -rf $@

doc:
	tar czf  gemlib-$(VERSION)-$@.tgz html

src:
	cd .. && make dist-gemlib
	cp ../gemlib-$(VERSION).tar.gz gemlib-$(VERSION)-src.tgz
