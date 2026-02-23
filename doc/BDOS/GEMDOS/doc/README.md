
**GEMDOS** consists of file system management routines that provide
access to all of the basic devices supported by Atari computers. It
bears resemblance to MS-DOS in its functions and opcode numbering while
still maintaining some differences and advantages.





Gemdos Error Numbers:
------ ----- --------
No.  Error             Comment

-32  invalid function     function doesn't exist
-33  file not found
-34  path not found       all or part of passed dir. doesn't exist
-35  too many open files  to many files OPEN'ed
-36  access impossible    problem using Gemdos
-37  invalid handle       handle passed is not an OPEN file
-38  wrong rez            program won't work in current rez
-39  not enough memory    -
-40  invalid memory block returning a memory blk that gemdos doesn't
                          recognise
-41  disc full            -
-42  not enough memory    see -39
-43  unknown              an error
-44  unknown              "    "
-45  unknown              "    "
-46  invalid drive        unknown drive
-47  invalid operation    bad data passed to functioin
-48  unknown              see -43
-49  no more files        see -35
-64  range error          number is to big to be stored correctly
-65  internal error       general OS problem
-66  invalid prog format  normally never returned (-35 used)
-67  setblock failure        "       "      "     (-39 used)
