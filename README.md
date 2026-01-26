# atari-tos

Atari ST TOS documents, source codes and development tools.

From various locations, including cross-compilers to create programs and ROM image.

https://docs.dev-docs.org

http://info-coach.fr/atari

https://www.yardley.cc/atari

https://bus-error.nokturnal.pl/atari_compendium/html/toc.htm

https://www.fplanque.com/tech/retro/atari/atari-st-fd-image-file-formats

https://github.com/freemint/tos.hyp/tree/gh-pages -> https://freemint.github.io/tos.hyp

* Sources

https://github.com/th-otto/tos1x

https://github.com/th-otto/tos3x

https://github.com/kelihlodversson/pTOS

https://github.com/ggnkua/Atari_ST_Sources

* Home

https://github.com/Kochise/atari-tos

* Also

[atari-docs] contains hardware documentations.

[atari-docs]: https://github.com/Kochise/atari-docs

[atari-emu] provides different emulators and bios images.

[atari-emu]: https://github.com/Kochise/atari-emu

## Architecture

Here is the general architecture of the TOS:

* TOS: The Operating System
	* GEM: Graphic Environment Manager
		* AES: Application Environment Services
		* VDI: Virtual Device Interface
		* GDOS: Graphics Device Operating System
	* BDOS: Basic Disk Operating System
		* BIOS: Basic Input Output System
		* XBIOS: eXtended Basic Input Output System
		* GEMDOS: GEM Disk Operating System
	* HARDWARE
		* CPU: Central Processing Unit
		* BLITTER: Bit
		* IO: Input Output

Each part is subdivided into functions, parameters and files.

```mermaid
%%{ init: { 'flowchart': { 'padding': 1, 'nodeSpacing': 24, 'rankSpacing': 1, 'diagramPadding': 1 }}}%%
flowchart TD
	subgraph TOS
		subgraph HARDWARE
			CPU
			BLITTER
			IO
			...
		end
		subgraph BDOS
			BIOS
			XBIOS
			GEMDOS
		end
		subgraph GEM
			AES
			VDI
			GDOS
		end
		subgraph VD[VIRTUAL DEVICES]
			subgraph DRIVER
				PRINTER
			end
			subgraph DESKTOP
				SCREEN
			end
		end
	end

	click CPU "https://github.com/Kochise/atari-docs/tree/master/CPU68030" _blank
	click BLITTER "https://github.com/Kochise/atari-docs/tree/master/BLITTER" _blank

	click BIOS "https://github.com/Kochise/atari-tos/tree/master/HAL/BIOS" _blank
	click XBIOS "https://github.com/Kochise/atari-tos/tree/master/HAL/XBIOS" _blank
	click GEMDOS "https://github.com/Kochise/atari-tos/tree/master/HAL/GEMDOS" _blank

	click AES "https://github.com/Kochise/atari-tos/tree/master/GEM/AES" _blank
	click VDI "https://github.com/Kochise/atari-tos/tree/master/GEM/VDI" _blank
	click GDOS "https://github.com/Kochise/atari-tos/tree/master/GEM/GDOS" _blank

	click SCREEN "https://github.com/Kochise/atari-tos/tree/master/VD/SCREEN" _blank
	click PRINTER "https://github.com/Kochise/atari-tos/tree/master/VD/PRINTER" _blank

	classDef lvl0 fill:#ffd,stroke:#ddb;
	classDef lvl1 fill:#eec,stroke:#cca;
	classDef lvl2 fill:#ddb,stroke:#bb9;
	classDef lvl3 fill:#cca,stroke:#aa8;
	classDef lvl4 fill:#bb9,stroke:#997;
	classDef lvl5 fill:#aa8,stroke:#886;

	class TOS lvl0;

	class HARDWARE lvl1
	class CPU lvl2
	class BLITTER lvl2
	class IO lvl2
	class ... lvl2

	class BDOS lvl1
	class BIOS lvl2
	class XBIOS lvl2
	class GEMDOS lvl2

	class GEM lvl1
	class AES lvl2
	class VDI lvl2
	class GDOS lvl2

	class VD lvl1
	class DESKTOP lvl2
	class SCREEN lvl3
	class DRIVER lvl2
	class PRINTER lvl3
```
