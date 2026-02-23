#include <stdio.h>
#include <dos.h>

/*
   doswap utility to be used to create or destroy a swappartition
   doswap -h prints a brief usage message
   doswap -c x: creates a swappartition of partition x if possible
   doswap -d destroys the current swappartition
   A swappartition is only created if there is no swappartition
   previously installed. Also a swappartition larger than 64 meg
   can't be created
   
   Sven Karlsson, Istari Software 1996
*/

extern __stdargs int  Check_magic(char *boot_sect_adr);
extern __stdargs void Put_magic(char *boot_sect_adr);
extern __stdargs void Clear_magic(char *boot_sect_adr);


int Check_if_installed(int Action,int Partition)
/* If Action = 0 then destroy the installed partition
   if Action = 1 then install a swappartition on partition Partition
                      if possible 
   returns false(0) if action is unsuccessful
   returns true(1) if action is successful
*/
{
 int  part;
 int  error;
 int  found=0;

 BPB  *part_info;
 char *boot_sector;
  
 for(part=2;(part<33)&&(!found);part++)
 {
  if (part_info=Getbpb(part))
  {
   if (!(boot_sector=malloc(part_info->recsiz)))
   {
    printf("Out of memory\n");
    return(0);
   }
   if(!Rwabs(0,boot_sector,1,0,part))
   {
    if (Check_magic(boot_sector))
    {
     found=part;
    }
    else
    {  
     free(boot_sector);
    }
   }
   else
   {
    free(boot_sector);
   }
  }
 }

 if (Action==0)
 {
  if (found)
  {
   printf("Destroying swappartition %c\nPlease reformat this partition before use!\n",found+65);
   Clear_magic(boot_sector);
   error=Rwabs(1,boot_sector,1,0,found);
   free(boot_sector);
   if (error)
   {
    printf("Could not write bootsector!\n");
   }
   return(!error) 
  }
  else
  {
   printf("No swappartition found!\n");
   return(0);
  }
 }
 else
 {
  free(boot_sector);
  if (found)
  {
   printf("A swappartition is already installed\non partition %c\n",found+65);
   return(0);
  }

  if (part_info=Getbpb(Partition))
  {
   if (!(boot_sector=malloc(part_info->recsiz)))
   {
    printf("Out of memory\n");
    return(0);
   }
   error=1;
   if(Rwabs(0,boot_sector,1,0,Partition))
   {
    printf("Could not read boot sector\n");
   }
   else
   {
    if ((part_info->numcl*part_info->clsizb)<0x04000000)
    {
     Put_magic(boot_sector);
     error=Rwabs(1,boot_sector,1,0,Partition);
     free(boot_sector);
     if (error)
     {
      printf("Could not write boot sector\n");
     }
    }
    else
    {
     printf("The partition is larger than 64 meg.\nCan not make swappartition!\n");
    }
    return(!error);
   }
   free(boot_sector);
   return(!error);
  }
  else
  {
   printf("Could not open partition %c\n",65+Partition);
  } 
 }
 return(0)
}

int main(int argc,char *argv[])
{
 char *str;
 char command;
 int  help=1;
 int  success;
 /*look at argv[1] */
 if (argc>1)
 {
  str=argv[1];
  if (*str++=='-')
  {
   if ((command=*str++)&&(!(*str)))
   {
    switch(command)
    {
     case 'd':
     {
      help=0;
      /* destroy swap */
      printf("Destroying swap!\n");
      success=Check_if_installed(0,0);
      break;
     }
     case 'c':
     {
      /* create swap */
      /* check argv[2] */
      if (argc==3)
      {
       str=argv[2];
       command=*str++;
       if (*str==':')
       {
        str++;
       }
       if (!(*str))
       {
        if (command>='a')
        {
         command-='a'-'A';
        }
        command-='A';
        if ((command>=0)&&(command<32))
        {
         help=0;
         printf("Creating swap at partition %c!\n",command+'A');
         success=Check_if_installed(1,command);
        }
       }
      }
      break;
     }
     case 'h':
      /* fall through */ 
     default:
     {
      break;
     }
    }
   }
  }
 }
 
 if (help)
 {
  printf("doswap utility to be used to create or destroy a swappartition\n\
doswap -h prints a brief usage message\n\
doswap -c x[:] creates a swappartition of partition x if possible\n\
doswap -d destroys the current swappartition\n\
A swappartition is only created if there is no swappartition\n\
previously installed. Also a swappartition larger than 64 meg\n\
can't be created\n\
\n\
MiNT must be rebooted to commit the changes!\n\
\n\
Sven Karlsson, Istari Software 1996\n");
 }
 else
 {
  if (!success)
  {
   printf("doswap failed! Something is wrong!\n");
  }
  else
  {
   printf("doswap successful!\n");
  }
 }
}    