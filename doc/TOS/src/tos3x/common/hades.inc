
/* TT/Hades SCSI register */
auu             equ $ffff8701 /* DMA Address Pointer (Highest byte) */
amu             equ $ffff8703 /* DMA Address Pointer (High byte) */
aml             equ $ffff8705 /* DMA Address Pointer (Low byte) */
all             equ $ffff8707 /* DMA Address Pointer (Lowest byte) */
cuu             equ $ffff8709 /* DMA Byte Count (Highest byte) */
cmu             equ $ffff870B /* DMA Byte Count (High byte) */
cml             equ $ffff870D /* DMA Byte Count (Low byte) */
cll             equ $ffff870F /* DMA Byte Count (Lowest byte) */
residue         equ $ffff8710 /* Residue Data Register */
dma_sctr1       equ $ffff8715 /* scsi control register.  bit 0 = scsi write. bit 1 = dma on. bit 6 = count 0. bit 7 = buserror */

/* hades hardwareregister */
dma_sctr2       equ $ffff8717   /* additional scsi control register.bit 0 = count0/eop. bit 1 = buserror */
psdm            equ $ffff8741   /* pseudo dma address for data */
main_status     equ $fff00080   /* Floppy Controller Chip Select */
data_reg        equ $fff00082   /* Floppy Controller Data */
ldor            equ $fff000c0	/* Floppy Controller Digital Output Register */
ldcr            equ $fff000e0	/* Floppy Controller Control Register */
pci_vga_base    equ $80000000   /* screen ram beginn */
isa_vga_base    equ $ff000000   /* screen ram beginn */
pci_vga_reg     equ $b0000000   /* vga register */
isa_vga_reg     equ $fff00000   /* vga register */
pci_base        equ $a0000000
pci_conf1       equ $a0010000   /* pci config */
pci_conf2       equ $a0020000   /* pci config */
pci_conf3       equ $a0040000   /* pci config */
pci_conf4       equ $a0080000   /* pci config */
