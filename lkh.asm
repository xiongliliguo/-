 DATA SEGMENT
    TABVAL  DW  262,277,294,311,330,349,370,392,415,440,466,494
            DW  523,554,587,622,659,698,740,784,831,880,932,988
            DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
    TABKEY  DB  '1','!','2','@','3','4','$','5','%','6','^','7'
            DB  'q','Q','w','e','E','r','R','t','T','y','Y','u'
            DB  'a','A','s','d','D','f','F','g','G','h','H','j'

    TABSIZE     DW  36
    PLAYCOUNT   DB  0;自动演奏计数n
    EXAMPLAY    DB  '1',1,'1',1,'5',1,'5',1,'6',1,'6',1,'5',2,'4',1,'4',1,'3',1,'3',1,'2',1,'2',1,'1',2,'$'
    ;EXAMPLAY    DB  '1',2,'5',2,'6',2,'5',2,'4',2,'3',2,'2',2,'1',2,'$'
    ERRORMSG    DB  '<-$'
    STARTMSG    DB  '->$'
	CUR  DB  0   ;应按的键
DATA ENDS

STCK SEGMENT STACK  
          db    100 DUP(?)  
STCK ENDS 

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
    LEA DI,EXAMPLAY;乐曲偏移地址给DI
    JMP PLAY
QUIT:
    POP DX
    POP CX
    POP BX
    POP AX
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
COUNT:    ;遍历音符
    MOV BL,PLAYCOUNT
    MOV BH,00H
    MOV DL,DI[BX];     DL当前要放的音
    CMP DL,'$'
    JZ QUIT
   ; MOV AH,02H
   ; INT 21H
    MOV CX,TABSIZE;表长
    MOV BX,0000H ;
FINDKEY:
    CMP DL,TABKEY[BX]
    JZ FIND
    ADD BX,1
    LOOP FINDKEY
    JMP ERROR
FIND:		;得值于TABKEY[BX]->DL  BX是key中找到的位置
    MOV DL,TABKEY[BX]
	MOV CUR,DL
    MOV AH,02H
    INT 21H
    ;频率-》BX 时长-》CX
    ;MOV CL,DI[PLAYCOUNT+1] 错 改成下三句
    MOV DX,BX
    ADD PLAYCOUNT,1
    MOV BL,PLAYCOUNT
	MOV BH,00H
    MOV CL,EXAMPLAY[BX]
	MOV BX,DX
    MOV DL,CL
    ADD DL,30H
    MOV AH,02H
    INT 21H
    MOV CH,00H ;  CX为持续时间  BX是key中找到的位置  
    JMP OUT_VOI
NEXT:
    ADD PLAYCOUNT,1
    JMP COUNT
    
ERROR:
    PUSH DX
    PUSH AX
    LEA DX,ERRORMSG
    MOV AH,09H
    INT 21H
    POP AX
    POP DX
    JMP QUIT

OUT_VOI:  
    PUSH AX
    PUSH DX
    PUSH CX
    ADD BX,BX
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
    
    JMP DELAY  
THEN:    
    IN AL,61H;             关闭与门  
    AND AL,0FCH;  
    OUT 61H,AL;

PUSH CX
DELAYLOOP3:
        MOV CX,1
        PUSH CX;
        MOV CX,0FFFFH  
    DELAYLOOP4:
        PUSH AX
        POP AX    
        LOOP DELAYLOOP4  
        POP CX; 
        LOOP DELAYLOOP3
POP CX
    POP DX
    POP AX
    JMP NEXT

DELAY:
    POP CX
    PUSH AX
    PUSH DX
    MOV DL,'-'
    MOV AH,02H
    DELAYLOOP1:   
        PUSH CX;
        MOV CX,0FFFFH  
    DELAYLOOP2:
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX     
        LOOP DELAYLOOP2  
        POP CX;
        INT 21H  
        LOOP DELAYLOOP1
    POP DX
    POP AX
    JMP THEN

CODE ENDS
    END START
