# atari-tos

Atari ST TOS documents, source codes and development tools.

From various sources, including cross-compiler to create programs and ROM image.

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
	* HAL: Hardware Abstraction Layer
		* GEMDOS: GEM Disk Operating System
		* BIOS: Basic Input Output System
		* XBIOS: eXtended Basic Input Output System
	* HARDWARE
		* CPU: Central Processing Unit
		* BLITTER: Bit
		* IO: Input Output

Each part is subdivided into functions, parameters and files.

```mermaid
flowchart TD
	subgraph TOS
		subgraph HARDWARE
			CPU
			BLITTER
			IO
			...
		end
		subgraph HAL
			GEMDOS
			BIOS
			XBIOS
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

	click GEMDOS "https://github.com/Kochise/atari-tos/tree/master/HAL/GEMDOS" _blank
	click BIOS "https://github.com/Kochise/atari-tos/tree/master/HAL/BIOS" _blank
	click XBIOS "https://github.com/Kochise/atari-tos/tree/master/HAL/XBIOS" _blank

	click AES "https://github.com/Kochise/atari-tos/tree/master/GEM/AES" _blank
	click VDI "https://github.com/Kochise/atari-tos/tree/master/GEM/VDI" _blank
	click GDOS "https://github.com/Kochise/atari-tos/tree/master/GEM/GDOS" _blank

	click PRINTER "https://github.com/Kochise/atari-tos/tree/master/VD/PRINTER" _blank
	click SCREEN "https://github.com/Kochise/atari-tos/tree/master/VD/SCREEN" _blank

	classDef lvl0 fill:#fc9,stroke:#da7;
	classDef lvl1 fill:#eb8,stroke:#c96;
	classDef lvl2 fill:#da7,stroke:#b85;
	classDef lvl3 fill:#c96,stroke:#a74;
	classDef lvl4 fill:#b85,stroke:#963;
	classDef lvl5 fill:#a74,stroke:#852;

	class TOS lvl0;

	class HARDWARE lvl1
	class CPU lvl2
	class BLITTER lvl2
	class IO lvl2
	class ... lvl2

	class HAL lvl1
	class GEMDOS lvl2
	class BIOS lvl2
	class XBIOS lvl2

	class GEM lvl1
	class AES lvl2
	class VDI lvl2
	class GDOS lvl2

	class VD lvl1
	class DRIVER lvl2
	class PRINTER lvl3
	class DESKTOP lvl2
	class SCREEN lvl3
```
