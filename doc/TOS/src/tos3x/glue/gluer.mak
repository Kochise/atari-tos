tosrsc$(COUNTRY).o: tosrsc$(COUNTRY).c rscend.h

tosrsc$(COUNTRY).c: $(MKBININC) glue.$(COUNTRY)
	$(AM_V_GEN)$(MKBININC) glue.$(COUNTRY) tosrsc $@

GEM_RSC = ../aes/rsc/$(TOSVERSION)/gem$(COUNTRY).rsc
DESK_RSC = ../desk/rsc/$(TOSVERSION)/desk$(COUNTRY).rsc
DESK_INF = ../desk/rsc/$(TOSVERSION)/desk$(COUNTRY).inf

-include localrsc.mak

GLUE_1_HADES = --hades

glue.$(COUNTRY): $(MKGLUE) $(GEM_RSC) $(DESK_RSC) $(DESK_INF)
	$(AM_V_GEN)$(MKGLUE) $(GLUE_$(HADES)_HADES) $(COUNTRY) $(TOSVERSION)

rscend.o: rscend.S
