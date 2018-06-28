 DATA SEGMENT
    INPROG  DW  2 DUP(?)
    TABVAL  DW  262,277,294,311,330,349,370,392,415,440,466,494
            DW  523,554,587,622,659,698,740,784,831,880,932,988
            DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
    TABKEY  DB  '1','!','2','@','3','4','$','5','%','6','^','7'
            DB  'q','Q','w','W','e','r','R','t','T','y','Y','u'
            DB  'a','A','s','S','d','f','F','g','G','h','H','j'
    TABSCAN  DB  02H,02H,03H,03H,04H,05H,05H,06H,06H,07H,07H,08H
               DB  10H,10H,11H,11H,12H,13H,13H,14H,14H,15H,15H,16H
               DB  1eH,1eH,1fH,1fH,20H,21H,21H,22H,22H,23H,23H,24H
    SHIFT   DB 0
    break   db  0
    pwait    db  0
    KEYDOWN DB 0
    SAOMIAO DB  '?'
    TABSIZE     DW  36
    PLAYCOUNT   DW  0;播放位置下标
    PLAY1   DB  'q',2,'q',2,'t',2,'t',2,'y',2,'y',2,'t',4,'r',2,'r',2,'e',2,'e',2,'w',2,'w',2,'q',4  ;灏忔槦鏄?
            DB  't',2,'t',2,'r',2,'r',2,'e',2,'e',2,'w',4,'t',2,'t',2,'r',2,'r',2,'e',2,'e',2,'w',4
            DB  'q',2,'q',2,'t',2,'t',2,'y',2,'y',2,'t',4,'r',2,'r',2,'e',2,'e',2,'w',2,'w',2,'q',4,'$'
            
    PLAY2   DB  'd',16,'s',16,'a',16,'u',16,'y',8,'t',8,'y',8  ;卡农
            DB  'u',8, 'a',2,'u',2,'a',2,'e',2, 't',4,'y',2,'u',2, 'a',2,'u',2,'a',2,'e',2, 'g',2,'d',2,'g',2,'h',2, 'f',2,'d',2,'s',2,'f',2, 'd',2,'s',2,'a',2,'u',2
            DB  'y',2,'t',2,'r',2,'a',2, 'u',8, 'y',2,'t',2,'r',2,'a',2, 'u',2,'t',2,'a',2,'u',2, 'g',2,'d',1,'f',1,'g',2,'d',1,'f',1, 'g',1,'t',1,'y',1,'u',1,'a',1,'s',1,'d',1,'f',1, 'd',2,'a',1,'s',1,'d',2,'d',1,'f',1
            DB  't',1,'y',1,'t',1,'e',1,'t',1,'a',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'y',2,'t',1,'r',1, 't',1,'r',1,'e',1,'r',1,'t',1,'y',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'a',2,'u',1,'y',1, 'u',1,'y',1,'u',1,'a',1,'s',1,'d',1,'f',1,'g',1
            DB  'd',2,'a',1,'s',1,'d',2,'s',1,'a',1, 's',1,'u',1,'a',1,'s',1,'d',1,'s',1,'a',1,'u',1, 'a',2,'y',1,'u',1,'a',2,'e',1,'r',1, 't',1,'y',1,'t',1,'r',1,'t',1,'a',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'y',2,'t',1,'r',1
            DB  't',1,'r',1,'e',1,'r',1,'t',1,'y',1,'u',1,'a',1, 'y',2,'a',1,'u',1,'a',2,'u',1,'y',1, 'u',1,'a',1,'s',1,'a',1,'u',1,'a',1,'y',1,'u',1, 'a',8, 't',8, 'y',8
            DB  'e',8, 'r',8, 'a',8, 'y',8, 'u',8, 'a',8,'$'
    
    ERRORMSG    DB  '...ERROR!$'
    STARTMSG    DB  'Welcome  in ',0ah,0dh          ;鎻愮ず淇℃伅              
                DB  '1.EXAMPLAY0',0ah,0dh
                DB  '2.EXAMPLAY1',0ah,0dh
                DB  '0.Quit:',0ah,0dh,'$'
    PLAYMSG     DB  '->$'
    ENDMSG      DB  '<-$'
	CUR  DB  0   ;搴旀寜鐨勯敭
DATA ENDS

STCK SEGMENT STACK  
          db    100 DUP(?)  
STCK ENDS 

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:

PRACTICE proc
    MOV AX,DATA
    MOV DS,AX
PRArestart:
    mov al,0
    mov break,al
    mov pwait,al
    CALL FAR PTR CLEAR
    LEA DX,STARTMSG;        输出提示信息,选择界面
    MOV AH,09H;
    INT 21H;
OTHER:
    MOV AH,01H;  接受按键
    INT 21H;
    CMP AL,'0';        
    JE FAR PTR PRAQUIT;     退出
    CMP AL,'1'
    JE PRACHOICE0
    CMP AL,'2'
    JE PRACHOICE1
    JMP PRArestart
PRACHOICE0:
    LEA DI,PLAY1; 涔愭洸1 鍋忕Щ鍦板潃缁橠I
    CALL PRAPLAY
    JMP PRArestart
PRACHOICE1:
    LEA DI,PLAY2; 涔愭洸2 鍋忕Щ鍦板潃缁橠I
    CALL PRAPLAY
    JMP PRArestart
PRAQUIT:
    MOV AH,4CH 
    INT 21H


PRAPLAY proc
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    CALL PRAPRINT

    MOV AX,0
    mov es,ax
    push es:[9*4]
    pop ds:[0]
    push es:[9*4+2]
    pop ds:[2]
    mov word ptr es:[9*4],offset PRATESTT
    mov es:[9*4+2],cs

    LEA DX,PLAYMSG
    MOV AH,09H
    INT 21H
    MOV PLAYCOUNT,0
    
PRACOUNT:    ;閬嶅巻闊崇??
    MOV KEYDOWN,0
    mov bl,pwait
    cmp bl,0ffh
    je PRAwaitin
    mov bl,break
    cmp bl,1
    je PRAPQUIT
    MOV BX,PLAYCOUNT
    MOV DL,DI[BX];     DL褰撳墠瑕佹斁鐨勯煶
    CMP DL,'$'
    JZ PRAprewait
    MOV CX,TABSIZE;琛ㄩ暱
    MOV BX,0000H ;
PRAFINDKEY:
    CMP DL,TABKEY[BX]
    JZ PRAFIND
    ADD BX,1
    LOOP PRAFINDKEY
    JMP PRAERROR
PRAprewait:
    mov bl,0ffh
    mov pwait,bl
PRAwaitin:
    mov bl,pwait
    cmp bl,0
    je PRACOUNT
    mov bl,break
    cmp bl,1
    je PRAPQUIT
    jmp PRAwaitin
PRAFIND:		;寰楀€间簬TABKEY[BX]->DL  BX鏄痥ey涓?鎵惧埌鐨勪綅缃?
    MOV DL,TABKEY[BX]
    MOV CUR,DL
    ;MOV AH,02H
    ;INT 21H
    ;棰戠巼-銆婤X 鏃堕暱-銆婥X
    MOV DX,BX
    ADD PLAYCOUNT,1
    MOV BX,PLAYCOUNT
    MOV CL,DI[BX]

	MOV BX,DX
    MOV CH,00H ;  CX涓烘寔缁?鏃堕棿  BX鏄痥ey涓?鎵惧埌鐨勪綅缃?  
    JMP PRAOUT_VOI
PRANEXT:
    ADD PLAYCOUNT,1
    JMP PRACOUNT
    
PRAERROR:
    PUSH DX
    PUSH AX
    LEA DX,ERRORMSG
    MOV AH,09H
    INT 21H
    POP AX
    POP DX
PRAPQUIT:
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

PRAOUT_VOI:  
    PUSH AX
    PUSH DX
    PUSH CX
    ADD BX,BX
    MOV AX,0000H;           甯哥啛120000H鍋氳??闄ゆ暟  
    MOV DX,0012H;  
    MOV BX,TABVAL[BX]
    DIV BX;      璁＄畻棰戠巼鍊?  
    MOV BX,AX;              灏嗕箣瀛樺叆BX瀵勫瓨鍣?  
    
    MOV AL,10110110B;       璁剧疆瀹氭椂鍣ㄥ伐浣滄柟寮?  
    OUT 43H,AL  
    
    MOV AX,BX;                
    OUT 42H,AL;             璁剧疆浣庝綅  
    
    MOV AL,AH;              璁剧疆楂樹綅  
    OUT 42H,AL  

    IN AL,61H;             鎵撳紑涓庨棬  
    OR AL,03H;  
    OUT 61H,AL  
    
    JMP PRADELAY  
PRATHEN:    
    IN AL,61H;             鍏抽棴涓庨棬  
    AND AL,0FCH;  
    OUT 61H,AL;
    PUSH CX
PRADELAYLOOP3:
        MOV CX,1
        PUSH CX;
        MOV CX,0FFFFH  
    PRADELAYLOOP4:
        PUSH AX
        POP AX    
        LOOP PRADELAYLOOP4  
        POP CX; 
        LOOP PRADELAYLOOP3

;///////////////////////////////////////////////////////////////////////////////
    MOV BX,PLAYCOUNT
    ; MOV DX,'A'
    ; MOV AH,02H;
    ; INT 21H;
    MOV CL,DI[BX];获得音长
    MOV CH,0
    CMP KEYDOWN,0
    JNZ PRAHASDOWN;////////////////////
    DEC BX;没按键盘
    MOV DL,DI[BX]
    MOV AH,02H;
    INT 21H;
    MOV DL,'?'
PRANOMINUS:
    INT 21H
    LOOP PRANOMINUS
    JMP PRAFINISHCOMP
PRAHASDOWN:
    MOV DL,SAOMIAO
    MOV AH,02H;
    INT 21H;
    DEC BX
    MOV AL,DI[BX]
    CMP AL,SAOMIAO
    JNZ PRAWRONGKEY
    MOV DL,'-'
    MOV AH,02H;
PRARIGHTMINUS:
    INT 21H;
    LOOP PRARIGHTMINUS
    JMP PRAFINISHCOMP
PRAWRONGKEY:
    MOV DL,'X'
    MOV AH,02H;
PRAWRONGMINUS:
    INT 21H;
    LOOP PRARIGHTMINUS
PRAFINISHCOMP:
    POP CX
    POP DX
    POP AX
    JMP PRANEXT

PRADELAY:
    POP CX
    PUSH AX
    PUSH DX
    PRADELAYLOOP1:   
        PUSH CX;
        MOV CX,0FFFFH  
    PRADELAYLOOP2:
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        PUSH AX
        POP AX
        LOOP PRADELAYLOOP2  
        POP CX; 
        LOOP PRADELAYLOOP1
    POP DX
    POP AX
    JMP PRATHEN
PRAPLAY ENDP

PRAPRINT proc
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV DL,'>'
    MOV AH,02H;
    INT 21H;
    MOV BX,0
PRATRAVERSAL:
    MOV DL,DI[BX];     DL褰撳墠瑕佹斁鐨勯煶
    CMP DL,'$'
    JZ PRAPRINTEND
    MOV AH,02H
    INT 21H
    INC BX
    MOV CL,DI[BX]
    MOV CH,0
PRAMINUS:
    MOV DL,'-'
    MOV AH,02H
    INT 21H
    LOOP PRAMINUS
    INC BX
    JMP PRATRAVERSAL
PRAPRINTEND:
    MOV DL,10
    MOV AH,02H
    INT 21H
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRAPRINT ENDP

PRACTICE ENDP

PRATESTT PROC
      push di
      push ax
      push bx
      push dx
      push es
      in al,60h   ;娴??0H缁旑垰褰涢懢宄板絿閹殿偅寮块惍?
      pushf
      pushf
      pop bx
      and bh,11111100b
      push bx
      popf
      call dword ptr ds:[0]   ;鐠嬪啰鏁ら崢鐒沶t9娑擃厽鏌?

      mov bl, al ;娣囨繂鐡╝l
    cmp al,39H
    je far ptr PRAiwait
    cmp al,01H
    jne PRAcon 
    mov al,1
    mov break,al
PRAcon:	  
    PRAMAIN:      ;按下或松开事件处理主要内容
      ;显示按下的扫描码
PRAJUDGE1:     ;判断是否为按下SHIFT
      cmp al,2aH  ;2aH是SHIFT的扫描码
      jnz PRAJUDGE2
      mov dl,1
      mov SHIFT,dl    ;用dx记录SHIFT状态 1为按下
      jmp PRAEXITNEWINT9
PRAiwait:
    mov al,pwait
    not al
    mov pwait,al
    jmp PRAcon
PRAJUDGE2:     ;判断是否为松开SHIFT
      cmp al,0aaH  ;aaH是SHIFT的断码
      jnz PRAVOICE
      mov dl,0
      mov SHIFT,dl    ;用dx记录SHIFT状态 0为松开
      jmp PRAEXITNEWINT9
PRAVOICE:     
      ;cmp al,02H ; 02h是1的扫描码//
      ;在TABSCAN中查找有没有与按下的键的扫描码对应的值
      push ax
      push es
      mov ax,ds
      mov es,ax   
      cld
      mov di,offset TABSCAN
      mov cx,36
      mov al,bl   ;串扫描字节(AL)-(ES:[DI])
      repne scasb
      
      jnz PRArelease
      
      ;计算输入字符在tabscan中对应的偏移量
      dec di
      mov ax,di
      mov di,offset TABSCAN
      sub ax,di   ;将初步偏移量放入ax中
      ;检测按下字符时SHIFT的状态
      mov dl,SHIFT
      cmp dl,1
      jnz PRAORIGIN  ;不等于1  跳转到ORIGIN（不做升调处理）
      ;否则升调（除了其中6种情况）
      mov dl,bl   ;扫描码放入dl中
      cmp dl,04H  ;判断是不是SHIFT+3
      jz PRArelease
      cmp dl,12H  ;判断是不是SHIFT+e
      jz PRArelease
      cmp dl,20H  ;判断是不是SHIFT+d
      jz PRArelease
      cmp dl,08H  ;判断是不是SHIFT+7
      jz PRArelease
      cmp dl,16H  ;判断是不是SHIFT+u
      jz PRArelease
      cmp dl,24H  ;判断是不是SHIFT+j
      jz PRArelease
      ;升调处理
      inc ax

PRAORIGIN:
      mov di,ax
      pop es
      pop ax
      push ax
      push bx
    mov bx,di
      mov dl,TABKEY[bx]
      mov SAOMIAO,dl
      INC KEYDOWN;///////////////////////////////////////////////////////
      pop bx
      pop ax
      jmp PRAEXITNEWINT9

PRArelease:    ;释放事件
      pop es
      pop ax 
      push ax
      pop ax
      jmp PRAEXITNEWINT9


PRAEXITNEWINT9:      ;结束该次响应9
      pop es
      pop dx
      pop bx
      pop ax
      pop di
      iret
PRATESTT ENDP

CLEAR PROC;清屏
    PUSH AX
    MOV AH,00H
    MOV AL,03H
    INT 10H
    POP AX
    RET
CLEAR ENDP

CODE ENDS
    END START
