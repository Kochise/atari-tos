  ORG P:0
P:[0000] 0af080 000040    jmp       P:0x0040

  ORG P:0x0c
P:[000c] 085eef           movep     X:0xffef,Y:(r6)+

  ORG P:0x10
P:[0010] 08dfef           movep     Y:(r7)+,X:0xffef

  ORG P:0x20
P:[0020] 085deb           movep     X:0xffeb,Y:(r5)+

  ORG P:0x22
P:[0022] 08d8eb           movep     Y:(r0)+,X:0xffeb

  ORG P:0x40
P:[0040] 08f4a1 0001f8    movep     #0x0001f8,X:0xffe1
P:[0042] 08f4ac 004700    movep     #0x004700,X:0xffec
P:[0044] 08f4ad 00f800    movep     #0x00f800,X:0xffed
P:[0046] 08f4be 000000    movep     #0x000000,X:0xfffe
P:[0048] 08f4a0 000001    movep     #0x000001,X:0xffe0
P:[004a] 0aa820           bset      #0,X:0xffe8
P:[004b] 0aa821           bset      #1,X:0xffe8
P:[004c] 08f4bf 003800    movep     #0x003800,X:0xffff
P:[004e] 362800           move      #0x28,r6
P:[004f] 0507a6           movec     #0x07,m6
P:[0050] 372000           move      #0x20,r7
P:[0051] 0507a7           movec     #0x07,m7
P:[0052] 350000           move      #0x00,r5
P:[0053] 051ba5           movec     #0x1b,m5
P:[0054] 302800           move      #0x28,r0
P:[0055] 0507a0           movec     #0x07,m0
P:[0056] 340000           move      #0x00,r4
P:[0057] 050fa4           movec     #0x0f,m4
P:[0058] 61f400 001000    move      #0x001000,r1
P:[005a] 05f421 000fff    movec     #0x000fff,m1
P:[005c] 71f400 000500    move      #0x000500,n1
P:[005e] 00fcb8           andi      #0xfc,mr
P:[005f] 0aae83 00005f    jclr      #3,X:0xffee,P:0x005f
P:[0061] 0aaea3 000061    jset      #3,X:0xffee,P:0x0061
P:[0063] 4da800           move      Y:0x0028,x1
P:[0064] 4f9000           move      Y:0x0010,y1
P:[0065] 4fdcf8           mpy       y1,x1,b Y:(r4)+,y1
P:[0066] 4ca9f0           mpy       y1,x1,a Y:0x0029,x0
P:[0067] 4e9100           move      Y:0x0011,y0
P:[0068] 4edcda           mac       y0,x0,b Y:(r4)+,y0
P:[0069] 4daad2           mac       y0,x0,a Y:0x002a,x1
P:[006a] 4f9200           move      Y:0x0012,y1
P:[006b] 4fdcfa           mac       y1,x1,b Y:(r4)+,y1
P:[006c] 4cabf2           mac       y1,x1,a Y:0x002b,x0
P:[006d] 4e9300           move      Y:0x0013,y0
P:[006e] 4edcda           mac       y0,x0,b Y:(r4)+,y0
P:[006f] 4dacd2           mac       y0,x0,a Y:0x002c,x1
P:[0070] 4f9400           move      Y:0x0014,y1
P:[0071] 4fdcfa           mac       y1,x1,b Y:(r4)+,y1
P:[0072] 4cadf2           mac       y1,x1,a Y:0x002d,x0
P:[0073] 4e9500           move      Y:0x0015,y0
P:[0074] 4edcda           mac       y0,x0,b Y:(r4)+,y0
P:[0075] 4daed2           mac       y0,x0,a Y:0x002e,x1
P:[0076] 4f9600           move      Y:0x0016,y1
P:[0077] 4fdcfa           mac       y1,x1,b Y:(r4)+,y1
P:[0078] 4caff2           mac       y1,x1,a Y:0x002f,x0
P:[0079] 4e9700           move      Y:0x0017,y0
P:[007a] 4edcda           mac       y0,x0,b Y:(r4)+,y0
P:[007b] 4ce1d2           mac       y0,x0,a Y:(r1),x0
P:[007c] 5d5900           move      b1,Y:(r1)+
P:[007d] 20001b           clr       b
P:[007e] 59e900           move      Y:(r1+n1),b0
P:[007f] 20003a           asl       b
P:[0080] 200048           add       x0,b
P:[0081] 21e400           move      b,x0
P:[0082] 4e9800           move      Y:0x0018,y0
P:[0083] 2000d2           mac       y0,x0,a
P:[0084] 4e9900           move      Y:0x0019,y0
P:[0085] 4da8d8           mpy       y0,x0,b Y:0x0028,x1
P:[0086] 4fdc00           move      Y:(r4)+,y1
P:[0087] 4ca9fa           mac       y1,x1,b Y:0x0029,x0
P:[0088] 4edc00           move      Y:(r4)+,y0
P:[0089] 4daada           mac       y0,x0,b Y:0x002a,x1
P:[008a] 4fdc00           move      Y:(r4)+,y1
P:[008b] 4cabfa           mac       y1,x1,b Y:0x002b,x0
P:[008c] 4edc00           move      Y:(r4)+,y0
P:[008d] 4dacda           mac       y0,x0,b Y:0x002c,x1
P:[008e] 4fdc00           move      Y:(r4)+,y1
P:[008f] 4cadfa           mac       y1,x1,b Y:0x002d,x0
P:[0090] 4edc00           move      Y:(r4)+,y0
P:[0091] 4daeda           mac       y0,x0,b Y:0x002e,x1
P:[0092] 4fdc00           move      Y:(r4)+,y1
P:[0093] 4caffa           mac       y1,x1,b Y:0x002f,x0
P:[0094] 4edc00           move      Y:(r4)+,y0
P:[0095] 2000da           mac       y0,x0,b
P:[0096] 15f000 00001a    move      a,x1 Y:0x001a,y1
P:[0098] 2000f0           mpy       y1,x1,a
P:[0099] 1df000 00001b    move      b,x1 Y:0x001b,y1
P:[009b] 2000f8           mpy       y1,x1,b
P:[009c] 5c2000           move      a1,Y:0x0020
P:[009d] 5d2100           move      b1,Y:0x0021
P:[009e] 0c005f           jmp       P:<0x005f

 END
