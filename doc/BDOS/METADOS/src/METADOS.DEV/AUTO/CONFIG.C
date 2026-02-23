;
; Config.sys	An ascii file that describes the system configuration.
;		This file is set up to use a hard disk 'C:' as the boot device.
;

; Physical Bios format
;*BOS, [Physical Bios driver][Arguments], [Physical id]:[DMA channel], ... 
*BOS, C:\AUTO\CDAR504.BOS, A:6

; Logical DOS format.
;*DOS  [Logical DOS] [Arguments], [Logical id]:[physical id],...
*DOS, C:\AUTO\HSMAY86.DRV, H:A
*DOS, C:\AUTO\ISO9660.DRV, I:A

;
; Load in the other "auto" folder files
;
; c:\auto\boot\ram512.tos		; Load in 512 byte ramdisk.
; c:\auto\boot\gdos11.tos		; Load in gdos11.
; c:\auto\boot\diab630.tos		; Load in diab 530 emulator.
; c:\auto\boot\sdump.tos		; Load in Screen dump to laser.
