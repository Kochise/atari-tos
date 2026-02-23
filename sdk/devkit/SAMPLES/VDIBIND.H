extern    WORD	*pioff, *iioff, *pooff, *iooff;

#define i_ptsin(ptr) pioff = ptr
#define i_intin(ptr) iioff = ptr
#define i_intout(ptr) iooff = ptr
#define i_ptsout(ptr) pooff = ptr
