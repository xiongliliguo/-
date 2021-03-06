﻿ DATA SEGMENT
    int9s   DW  2   dup(?)
    TABVAL  DW  262,277,294,311,330,349,370,392,415,440,466,494
            DW  523,554,587,622,659,698,740,784,831,880,932,988
            DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
    TABKEY  DB  '1','!','2','@','3','4','$','5','%','6','^','7'
            DB  'q','Q','w','W','e','r','R','t','T','y','Y','u'
            DB  'a','A','s','S','d','f','F','g','G','h','H','j'

    TABSIZE     DW  36 ;
    PLAYCOUNT   dw  0;自动演奏计数n
    break   db  0
    pwait    db  0
    PLAY1   DB  'q',2,'q',2,'t',2,'t',2,'y',2,'y',2,'t',4,'r',2,'r',2,'e',2,'e',2,'w',2,'w',2,'q',4  ;小星星
            DB  't',2,'t',2,'r',2,'r',2,'e',2,'e',2,'w',4,'t',2,'t',2,'r',2,'r',2,'e',2,'e',2,'w',4
            DB  'q',2,'q',2,'t',2,'t',2,'y',2,'y',2,'t',4,'r',2,'r',2,'e',2,'e',2,'w',2,'w',2,'q',4,'$'
            
    PLAY2   DB  'd',8,'s',8,'a',8,'u',8,'y',8,'t',8,'y',8  ;卡农
            DB  'u',8, 'a',2,'u',2,'a',2,'e',2, 't',4,'y',2,'u',2, 'a',2,'u',2,'a',2,'e',2, 'g',2,'d',2,'g',2,'h',2, 'f',2,'d',2,'s',2,'f',2, 'd',2,'s',2,'a',2,'u',2
            DB  'y',2,'t',2,'r',2,'a',2, 'u',8, 'y',2,'t',2,'r',2,'a',2, 'u',2,'t',2,'a',2,'u',2, 'g',2,'d',1,'f',1,'g',2,'d',1,'f',1, 'g',1,'t',1,'y',1,'u',1,'a',1,'s',1,'d',1,'f',1, 'd',2,'a',1,'s',1,'d',2,'d',1,'f',1
            DB  't',1,'y',1,'t',1,'e',1,'t',1,'a',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'y',2,'t',1,'r',1, 't',1,'r',1,'e',1,'r',1,'t',1,'y',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'a',2,'u',1,'y',1, 'u',1,'y',1,'u',1,'a',1,'s',1,'d',1,'f',1,'g',1
            DB  'd',2,'a',1,'s',1,'d',2,'s',1,'a',1, 's',1,'u',1,'a',1,'s',1,'d',1,'s',1,'a',1,'u',1, 'a',2,'y',1,'u',1,'a',2,'e',1,'r',1, 't',1,'y',1,'t',1,'r',1,'t',1,'a',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'y',2,'t',1,'r',1
            DB  't',1,'r',1,'e',1,'r',1,'t',1,'y',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'a',2,'u',1,'y',1, 'u',1,'a',1,'s',1,'a',1,'u',1,'a',1,'y',1,'u',1, 'a',8, 't',8, 'y',8
            DB  'e',8, 'r',8, 'a',8, 'y',8, 'u',8, 'a',8,'$'
    ERRORMSG    DB  '...ERROR!$'
    STARTMSG    DB  'Welcome  in ',0ah,0dh          ;提示信息              
                DB  '1.EXAMPLAY0',0ah,0dh
                DB  '2.EXAMPLAY1',0ah,0dh
                DB  '0.Quit:',0ah,0dh,'$'
    PLAYMSG     DB  '->$'
    ENDMSG      DB  '<-$'
	CUR  DB  0   ;应按的键
DATA ENDS

STCK SEGMENT STACK  
          db    100 DUP(?)  
STCK ENDS 
CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:

MUSIC proc
    MOV AX,DATA
    MOV DS,AX
MUrestart:
    mov al,0
    mov break,al
    mov pwait,al
    CALL FAR PTR CLEAR
    LEA DX,STARTMSG;        输出提示信息,选择界面
    MOV AH,09H;
    INT 21H;
    MOV AH,01H;  接受按键
    INT 21H;
    CMP AL,'0';        
    JE FAR PTR MUQUIT;     退出
    CMP AL,'1'
    JE MUCHOICE0
    CMP AL,'2'
    JE MUCHOICE1
    jmp MUrestart

MUCHOICE0:
    LEA DI,PLAY1; 乐曲1 偏移地址给DI
    CALL MUPLAY
    JMP MUrestart
MUCHOICE1:
    LEA DI,PLAY2; 乐曲2 偏移地址给DI
    CALL MUPLAY
    JMP MUrestart
MUQUIT:
    MOV AH,4CH 
    INT 21H

MUPLAY proc
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    mov ax,0
    mov es,ax
    push es:[9*4]
    pop ds:[0]
    push es:[9*4+2]
    pop ds:[2]
    mov word ptr es:[9*4],offset MUmyint9
    mov es:[9*4+2],cs

    LEA DX,PLAYMSG
    MOV AH,09H
    INT 21H
    MOV PLAYCOUNT,0
MUCOUNT:    ;遍历音符
    mov bl,pwait
    cmp bl,0ffh
    je MUwaitin
    mov bl,break
    cmp bl,1
    je MUPQUIT
    MOV BX,PLAYCOUNT
    MOV DL,DI[BX];     DL当前要放的音
    CMP DL,'$'
    JZ MUprewait
    MOV CX,TABSIZE;表长
    MOV BX,0000H ;
MUFINDKEY:
    CMP DL,TABKEY[BX]
    JZ MUFIND
    ADD BX,1
    LOOP MUFINDKEY
    JMP MUERROR
MUprewait:
    mov bl,0ffh
    mov pwait,bl
MUwaitin:
    mov bl,pwait
    cmp bl,0
    je MUCOUNT
    mov bl,break
    cmp bl,1
    je MUPQUIT
    jmp MUwaitin
MUFIND:		;得值于TABKEY[BX]->DL  BX是key中找到的位置
    MOV DL,TABKEY[BX]
	MOV CUR,DL
    MOV AH,02H
    INT 21H
    ;频率-》BX 时长-》CX
    MOV DX,BX
    ADD PLAYCOUNT,1
    MOV BX,PLAYCOUNT
    MOV CL,DI[BX]
	MOV BX,DX
    MOV CH,00H ;  CX为持续时间  BX是key中找到的位置  
    JMP MUOUT_VOI
MUNEXT:
    ADD PLAYCOUNT,1
    JMP MUCOUNT
    
MUERROR:
    PUSH DX
    PUSH AX
    LEA DX,ERRORMSG
    MOV AH,09H
    INT 21H
    POP AX
    POP DX
MUPQUIT:

    mov ax,0
    mov es,ax
    push ds:[0]
    pop es:[9*4]
    push ds:[2]
    pop es:[9*4+2]

    POP DX
    POP CX
    POP BX
    POP AX
    RET

MUOUT_VOI:  
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
    JMP MUDELAY  
MUTHEN:    
    IN AL,61H;             关闭与门  
    AND AL,0FCH;  
    OUT 61H,AL;
    PUSH CX
MUDELAYLOOP3:
        MOV CX,1
        PUSH CX;
        MOV CX,0FFFFH  
    MUDELAYLOOP4:
        PUSH AX
        POP AX    
        LOOP MUDELAYLOOP4  
        POP CX; 
        LOOP MUDELAYLOOP3
    POP CX
    POP DX
    POP AX
    JMP MUNEXT

MUDELAY:
    POP CX
    PUSH AX
    PUSH DX
    MOV DL,'-'
    MOV AH,02H
    MUDELAYLOOP1:   
        PUSH CX;
        MOV CX,0FFFFH  
    MUDELAYLOOP2:
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        LOOP MUDELAYLOOP2  
        POP CX;
        INT 21H  
        LOOP MUDELAYLOOP1
    POP DX
    POP AX
    JMP MUTHEN
MUplay endp

CLEAR PROC;清屏
    PUSH AX
    MOV AH,00H
    MOV AL,03H
    INT 10H
    POP AX
    RET
CLEAR ENDP

MUSIC ENDP

MUmyint9 proc
    push ax
    push bx
    push cx
    push dx

    in al,60H
    pushf
    pushf
    pop bx
    and bh,11111100b
    push bx
    popf
    call dword ptr ds:[0]
    cmp al,39H
    je MUiwait
    cmp al,01H
    jne MUcon 
    mov al,1
    mov break,al
MUcon:
    pop dx
    pop cx
    pop bx
    pop ax
    iret
MUiwait:
    mov al,pwait
    not al
    mov pwait,al
    jmp MUcon
MUmyint9 endp
CODE ENDS
    END START
