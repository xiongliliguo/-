DATA SEGMENT
    TABVAL  DW  262,277,294,311,330,349,370,392,415,440,466,494
            DW  523,554,587,622,659,698,740,784,831,880,932,988
            DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
    TABKEY  DB  '1','!','2','@','3','4','$','5','%','6','^','7'
            DB  'q','Q','w','e','E','r','R','t','T','y','Y','u'
            DB  'a','A','s','d','D','f','F','g','G','h','H','j'

    TABSIZE     DB  36
    PLAYCOUNT   DB  0;自动演奏计数n
    EXAMPLAY    DB  '!',3,'2',4,'3',4,'4',4,'5',1,'6',2,'7',3,'$'
    ERRORMSG    DB  'ERROR!$'
    STARTMSG    DB  '->$'
DATA ENDS

STCK SEGMENT STACK  
          db    100 DUP(?)  
STCK ENDS 

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
    LEA DI,EXAMPLAY;演奏示例
    JMP PLAY
QUIT:
    MOV AH,4CH
    INT 21H

PLAY:
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    LEA DX,STARTMSG
    MOV AH,09H
    INT 21H
    MOV PLAYCOUNT,0
COUNT:
    MOV BL,PLAYCOUNT
    MOV BH,00H
    MOV DL,DI[BX];第n个音
    CMP DL,'$'
    JZ QUIT
   ; MOV AH,02H
   ; INT 21H
    
    MOV CL,TABSIZE;表长
    MOV BX,0 ;
FINDKEY:
    CMP DL,TABKEY[BX]
    JZ FIND
    ADD BX,1
    SUB CL,1
    JNZ FINDKEY
    JMP ERROR
FIND:
    MOV DL,TABKEY[BX]
    MOV AH,02H
    INT 21H
    ;频率-》BX 时长-》CX
    MOV CL,DI[PLAYCOUNT+1]
    ;MOV DL,CL
    ;MOV AH,02H
    ;INT 21H
    MOV CH,00H
    JMP OUT_VOI
NEXT:
    ADD PLAYCOUNT,2
    JMP COUNT
ERROR:
    LEA DX,ERRORMSG
    MOV AH,9
    INT 21H
    JMP QUIT


OUT_VOI:  
    PUSH AX
    PUSH DX
    PUSH CX
    MOV AX,0000H;           常熟120000H做被除数  
    MOV DX,0012H;  
    MOV BX,TABVAL[BX]
    DIV BX;      计算频率值  
    MOV BX,AX;              将之存入BX寄存器  
    
    MOV AL,10110110B;       设置定时器工作方式  
    OUT 43H,AL  
    
    MOV AX,BX;                
    OUT 42H,AL;             设置低位  
    
    MOV AL,AH;              设置高位  
    OUT 42H,AL  

    IN AL,61H;             打开与门  
    OR AL,03H;  
    OUT 61H,AL  
    
    CALL DELAY  
    
    IN AL,61H;             关闭与门  
    AND AL,0FCH;  
    OUT 61H,AL;

    POP DX
    POP AX
    JMP NEXT

DELAY  PROC  
    POP CX
    MOV DL,'-'
    MOV AH,2    
    DELAYLOOP1:   
        PUSH CX;  
        MOV CX,0FFFFH  
    DELAYLOOP2:  
        LOOP DELAYLOOP2  
        POP CX;
        INT 21H  
        LOOP DELAYLOOP1  
    RET  
DELAY ENDP

CODE ENDS
    END START
