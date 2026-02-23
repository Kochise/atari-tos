top_srcdir=.

include GNUmakefile.cmn
include Makefile.sil

SUBDIRS = common tools tospatch bios vdi bdos aes desk system glue
EXTRA_SUBDIRS = alcyon alcyon/orig

EXTRA_DIST1 = \
	Makefile \
	Makefile.cmn \
	Makefile.sil \
	config.mak \
	README \
	$(empty)

EXTRA_DIST2 = \
	GNUmakefile \
	GNUmakefile.cmn \
	$(empty)

all::
	@:

include $(top_srcdir)/config.mak

FLAGSTOPASS = COUNTRY=$(COUNTRY) TOSVERSION=$(TOSVERSION) HADES=$(HADES) MEDUSA=$(MEDUSA)

dist::
	rm -rf $(DISTDIR1) $(DISTDIR2)
	for i in $(SUBDIRS) lib; do $(MKDIR_P) $(DISTDIR1)/$$i; done
	for i in $(SUBDIRS) $(EXTRA_SUBDIRS) listings; do $(MKDIR_P) $(DISTDIR2)/$$i; done

all dist::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $(FLAGSTOPASS) $@ || exit 1; done

clean distclean::
	for i in $(SUBDIRS); do $(MAKE) -C $$i $(FLAGSTOPASS) $@; done

dist::
	for i in $(EXTRA_SUBDIRS); do $(MAKE) -C $$i $@; done

check::
	for i in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$i $(FLAGSTOPASS) all; done
	for i in $(SUBDIRS); do $(MAKE) --no-print-directory -C $$i $(FLAGSTOPASS) $@; done

checkall::
	for version in 306 206; do \
		for lang in us de fr es it se sf sg uk; do \
			$(MAKE) clean >/dev/null; \
			echo "CHECK: $$version $$lang"; \
			$(MAKE) TOSVERSION=$${version} COUNTRY=$${lang} HADES=0 MEDUSA=0 check >/dev/null || exit 1; \
		done; \
	done
	for version in 208; do \
		for lang in de us fr; do \
			$(MAKE) clean >/dev/null; \
			echo "CHECK: $$version $$lang"; \
			$(MAKE) TOSVERSION=$${version} COUNTRY=$${lang} HADES=0 MEDUSA=0 check >/dev/null || exit 1; \
		done; \
	done
	$(MAKE) clean >/dev/null
	echo "CHECK: Hades 306 uk"
	$(MAKE) TOSVERSION=306 COUNTRY=uk HADES=1 MEDUSA=0 check >/dev/null
	$(MAKE) clean >/dev/null
	echo "CHECK: Medusa 206 de"
	$(MAKE) TOSVERSION=206 COUNTRY=de HADES=0 MEDUSA=1 check >/dev/null
	$(MAKE) clean >/dev/null
	echo "CHECK: Medusa 306 de"
	$(MAKE) TOSVERSION=306 COUNTRY=de HADES=0 MEDUSA=1 check >/dev/null
	$(MAKE) clean >/dev/null

rsync::
	for i in $(SUBDIRS) include GNUmakefile GNUmakefile.cmn config.mak; do sudo rsync -vzrlpt $$i $(LOCAL_WWWDIR); done
	sudo chown -R wwwrun:www $(LOCAL_WWWDIR)
	sudo chmod -R g+w $(LOCAL_WWWDIR)

maps:
	for version in 306 206; do \
		for lang in us de fr es it se sf sg uk; do \
			$(MAKE) clean; \
			$(MAKE) SYMBOLS=-s TOSVERSION=$${version} COUNTRY=$${lang} HADES=0 MEDUSA=0 || exit 1; \
			cnm glue/tos.img | sort | uniq > glue/tos$${version}$${lang}.map; \
		done; \
	done
	for version in 208; do \
		for lang in de us fr; do \
			$(MAKE) clean; \
			$(MAKE) SYMBOLS=-s TOSVERSION=$${version} COUNTRY=$${lang} HADES=0 MEDUSA=0 || exit 1; \
			cnm glue/tos.img | sort | uniq > glue/tos$${version}$${lang}.map; \
		done; \
	done
	$(MAKE) clean
	$(RM) glue/*.img glue/glue.*

#
# generate cleaned up symbol maps for hatari,
# by removing symbols that refer to duplicate addresses etc.
#
.PHONY: hatari
hatari:
	for version in 104 106 162 206 306; do \
		for lang in us de fr es it se sf sg uk cz dk nl pl; do \
			if test -f glue/tos$${version}$${lang}.map; then \
			$(SED) -e '/ cart_base$$/d' \
			       -e '/ gr_rect$$/d' \
			       -e '/ gr_gtext$$/d' \
			       -e '/ ig_fix$$/d' \
			       -e '/ dos_gdrv$$/d' \
			       -e '/ dos_sdrv$$/d' \
			       -e '/ _dos_ffree$$/d' \
			       -e '/ gr_xor$$/d' \
			       -e '/ _gr_fmovebox$$/d' \
			       -e '/ gr_movebox$$/d' \
			       -e '/ gr_scale$$/d' \
			       -e '/ gr_stilldn$$/d' \
			       -e '/ ez_glrsr$$/d' \
			       -e '/ gr_setup$$/d' \
			       -e '/ gr_rubwind$$/d' \
			       -e '/ _gr_fdragbox$$/d' \
			       -e '/ _gsx_acode$$/d' \
			       -e '/ gsx_ncode$$/d' \
			       -e '/ _gsx_1acode$$/d' \
			       -e '/ gsx_1code$$/d' \
			       -e '/ _gsx_fmxmy$$/d' \
			       -e '/ _gsx_fmoff$$/d' \
			       -e '/ gsx_moff$$/d' \
			       -e '/ ig_moff$$/d' \
			       -e '/ vro_cpyfm$$/d' \
			       -e '/ _ob_fdelete$$/d' \
			       -e '/ _ob_factxywh$$/d' \
			       -e '/ _ob_foffset$$/d' \
			       -e '/ _rc_fequal$$/d' \
			       -e '/ _rc_fconstrain$$/d' \
			       -e '/ _inf_fgindex$$/d' \
			       -e '/ _feveryobj$$/d' \
			       -e '/ b_delay$$/d' \
			       -e '/ _trp14int$$/d' \
			       -e '/ BM_SM$$/d' \
			       -e '/ BM_HOG$$/d' \
			       -e '/ BM_GO$$/d' \
			       -e '/ a /d' \
			       -e 's/ A / B /' \
			       -e '/ _proc_lives$$/d' \
			       -e '/ _proc_dregs$$/d' \
			       -e '/ _proc_aregs$$/d' \
			       -e '/ _proc_enum$$/d' \
			       -e '/ _proc_usp$$/d' \
			       -e '/ _proc_stk$$/d' \
			       -e '/ _etv_timer$$/d' \
			       -e '/ sysvars_start$$/d' \
			       -e '/ _etv_critic$$/d' \
			       -e '/ _etv_term$$/d' \
			       -e '/ _etv_xtra$$/d' \
			       -e '/ _memvalid$$/d' \
			       -e '/ memctrl$$/d' \
			       -e '/ resvalid$$/d' \
			       -e '/ resvector$$/d' \
			       -e '/ _phystop$$/d' \
			       -e '/ _membot$$/d' \
			       -e '/ _memtop$$/d' \
			       -e '/ _memval2$$/d' \
			       -e '/ _flock$$/d' \
			       -e '/ _seekrate$$/d' \
			       -e '/ _timer_ms$$/d' \
			       -e '/ _fverify$$/d' \
			       -e '/ _bootdev$$/d' \
			       -e '/ _palmode$$/d' \
			       -e '/ _defshiftmod$$/d' \
			       -e '/ _sshiftmod$$/d' \
			       -e '/ _v_bas_ad$$/d' \
			       -e '/ _vblsem$$/d' \
			       -e '/ _nvbls$$/d' \
			       -e '/ _vblqueue$$/d' \
			       -e '/ _colorptr$$/d' \
			       -e '/ _screenpt$$/d' \
			       -e '/ _vbclock$$/d' \
			       -e '/ _frclock$$/d' \
			       -e '/ _hdv_init$$/d' \
			       -e '/ _swv_vec$$/d' \
			       -e '/ _hdv_bpb$$/d' \
			       -e '/ _hdv_rw$$/d' \
			       -e '/ _hdv_boot$$/d' \
			       -e '/ _hdv_mediach$$/d' \
			       -e '/ _cmdload$$/d' \
			       -e '/ _conterm$$/d' \
			       -e '/ _themd$$/d' \
			       -e '/ ____md$$/d' \
			       -e '/ _savptr$$/d' \
			       -e '/ _nflops$$/d' \
			       -e '/ con_state$$/d' \
			       -e '/ _save_row$$/d' \
			       -e '/ sav_context$$/d' \
			       -e '/ _bufl$$/d' \
			       -e '/ _hz_200$$/d' \
			       -e '/ the_env$$/d' \
			       -e '/ _drvbits$$/d' \
			       -e '/ _dskbufp$$/d' \
			       -e '/ _autopath$$/d' \
			       -e '/ _vbl_list$$/d' \
			       -e '/ _dumpflg$$/d' \
			       -e '/ _sysbase$$/d' \
			       -e '/ _shell_p$$/d' \
			       -e '/ _end_os$$/d' \
			       -e '/ _exec_os$$/d' \
			       -e '/ _scr_dmp$$/d' \
			       -e '/ _prt_stat$$/d' \
			       -e '/ _prt_vec$$/d' \
			       -e '/ _aux_stat$$/d' \
			       -e '/ _aux_vec$$/d' \
			       -e '/ _pun_ptr$$/d' \
			       -e '/ _memval3$$/d' \
			       -e '/ _bconstat_vec$$/d' \
			       -e '/ _bconin_vec$$/d' \
			       -e '/ _bcostat_vec$$/d' \
			       -e '/ _bconout_vec$$/d' \
			       -e '/ _longframe$$/d' \
			       -e '/ _p_cookies$$/d' \
			       -e '/ _ramtop$$/d' \
			       -e '/ _ramvalid$$/d' \
			       -e '/ _bell_hook$$/d' \
			       -e '/ _kcl_hook$$/d' \
				glue/tos$${version}$${lang}.map > hatari/tos$${version}$${lang}.sym; \
			fi; \
		done; \
	done

dosdir::
	for i in $(SUBDIRS) lib bin/tos; do $(MKDIR_P) $(DOSDIR)/$$i; done
	for i in $(SUBDIRS); do $(MAKE) -C $$i $@; done
	$(CP) -a $(EXTRA_DIST1) $(DOSDIR)
	$(CP) -a -r include $(DOSDIR)
	$(CP) -a -r bin/tos $(DOSDIR)/bin
	$(CP) -a -r aes/rsc $(DOSDIR)/aes
	$(CP) -a -r desk/rsc $(DOSDIR)/desk
	$(CP) -a lib/*.o lib/*.a lib/*.ndx lib/as68symb.dat $(DOSDIR)/lib
	for i in as68 cp68 c068 c168 link68 size68 optimize relmod nm68 ar68; do $(RM) $(DOSDIR)/bin/$$i; done

dist::
	$(CP) -a $(EXTRA_DIST1) $(EXTRA_DIST2) $(DISTDIR1)
	$(CP) -a -r include $(DISTDIR1)
	$(CP) -a -r bin $(DISTDIR1)
	$(CP) -a -r aes/rsc $(DISTDIR1)/aes
	$(CP) -a -r desk/rsc $(DISTDIR1)/desk
	$(CP) -a lib/*.o lib/*.a lib/*.ndx lib/as68symb.dat $(DISTDIR1)/lib
	$(CP) -a listings/tos306de.s $(DISTDIR2)/listings
	(cd $(DISTDIR1)/..; rm -f tos306de.tar.bz2; tar cvfj tos306de.tar.bz2 tos306de)
	(cd $(DISTDIR2)/..; rm -f alcyon.tar.bz2; tar cvfj alcyon.tar.bz2 alcyon)
	test -d "$(WWWDIR)" && cp $(DISTDIR1)/../tos306de.tar.bz2 "$(WWWDIR)"
	test -d "$(WWWDIR)" && cp $(DISTDIR2)/../alcyon.tar.bz2 "$(WWWDIR)"

help::
	@echo ""
	@echo "targets:"
	@echo "   all       - build default configuration TOSVERSION=$(TOSVERSION) COUNTRY=$(COUNTRY)"
	@echo "   clean     - remove temporary files"
	@echo "   distclean - remove all generated files"
	@echo ""
	@echo "The resulting output file will be glue/tos$(TOSVERSION)$(COUNTRY).img"
	@echo ""
	@echo "See $(top_srcdir)/config.mak for a list of valid configurations"
