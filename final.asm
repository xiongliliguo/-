DATA SEGMENT
    int9s   DW  2   dup(?)
    TABVAL  DW  262,277,294,311,330,349,370,392,415,440,466,494
            DW  523,554,587,622,659,698,740,784,831,880,932,988
            DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
    TABKEY  DB  '1','!','2','@','3','4','$','5','%','6','^','7'
            DB  'q','Q','w','W','e','r','R','t','T','y','Y','u'
            DB  'a','A','s','S','d','f','F','g','G','h','H','j'

    TABSCAN     DB  02H,02H,03H,03H,04H,05H,05H,06H,06H,07H,07H,08H
                DB  10H,10H,11H,11H,12H,13H,13H,14H,14H,15H,15H,16H
                DB  1eH,1eH,1fH,1fH,20H,21H,21H,22H,22H,23H,23H,24H
    
    TABSIZE     DW  36
    SHIFT       DB  00H
    PLAYCOUNT   Dw  0;自动演奏计数n
    KEYDOWN     DB 0
    SAOMIAO     DB  '?'
    CUR         DB  0   ;搴旀寜鐨勯敭
    break       db  0
    pwait       db  0
    picount     dw  0

    buf             db      600 dup('$')        ;文件内容暂存区
    error_message   db      0ah , 'error !' , '$'    ;出错时的提示
    handle          dw      ?                ;保存文件号
    writebuf db 260 dup(?);用来存写入的内容
    newfile  db 64  dup(?);用来存文件名
    info1    db 'input file name:$'
    file     db  'c:\test.txt' , 0       ;文件名

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
    MENUMSG DB 20 DUP(' '),'       Welcome to piano Player        ',13,10
            DB 20 DUP(' '),'**************MENU********************',13,10 
            DB 20 DUP(' '),'**1:Play the piano                  **',13,10 
            DB 20 DUP(' '),'**2:Play the music                  **',13,10
            DB 20 DUP(' '),'**3:Practice                        **',13,10
            DB 20 DUP(' '),'**4:Edit file                       **',13,10 
            DB 20 DUP(' '),'**0:Exit;                           **',13,10     
            DB 20 DUP(' '),'**************************************',13,10,'$'  
    ERRORMSG    DB  '...ERROR!$'
    STARTMSG    DB  'Welcome  in ',0ah,0dh          ;提示信息              
                DB  '1.EXAMPLAY0',0ah,0dh
                DB  '2.EXAMPLAY1',0ah,0dh
                DB  '3.FILE:test.txt',0ah,0dh
                DB  '0.Quit:',0ah,0dh,'$'
    PLAYMSG     DB  '->$'
    ENDMSG      DB  '<<<$'
    
DATA ENDS

STCK SEGMENT STACK  
          db    100 DUP(?)  
STCK ENDS 

CODE SEGMENT
    ASSUME CS:CODE,DS:DATA
START:
    MOV AX,DATA
    MOV DS,AX
MENU:
    CALL CLEAR
    LEA DX,MENUMSG
    MOV AH,09H
    INT 21H

    MOV AH,01H;  
    INT 21H;

    CMP AL,'1';        
    JE MECHOICE1
    CMP AL,'2'
    JE MECHOICE2
    CMP AL,'3'
    JE MECHOICE3
    CMP AL,'4'
    JE MECHOICE4
    CMP AL,'0'
    JE MEQUIT
    jmp MENU
MECHOICE1:
    CALL CLEAR
    CALL PIANO
    push cx
    push ax
    mov cx,picount
    MOV AH,01H
MEre:
    INT 21H
    loop MEre
    mov picount,cx
    pop ax
    pop cx  
    JMP MENU
MECHOICE2:
    CALL CLEAR
    CALL MUSIC
    JMP MENU
MECHOICE3:
    CALL CLEAR
    CALL PRACTICE
    JMP MENU
MECHOICE4:
    CALL CLEAR
    CALL WRITE
    JMP MENU
MEQUIT:
    MOV AH,4CH;  
    INT 21H; 

CLEAR PROC;清屏
    PUSH AX
    MOV AH,00H
    MOV AL,03H
    INT 10H
    POP AX
    RET
CLEAR ENDP

PIANO proc
      push ax
      push bx
      push cx
      push dx
     ; 改中断例程入口地址
      mov ax,0
      mov picount,ax
      mov es,ax
      push es:[9*4]
      pop ds:[0]
      push es:[9*4+2]
      pop ds:[2]
      mov word ptr es:[9*4],offset piNEWINT9
      mov es:[9*4+2],cs
piLOOPMAIN:
    push bx
    mov bl,break
    cmp bl,1
    je piQuit
    pop bx
    jmp piLOOPMAIN   ;死循环，等待中断到来

piQuit:
      pop bx
      mov ax,0
      mov break,al
      mov es,ax

      push ds:[0]
      pop es:[9*4]
      push ds:[2]
      pop es:[9*4+2]

      pop dx
      pop cx
      pop bx
      pop ax
      ret
; 定义中断例程

PIANO endp

piNEWINT9 proc
      push ax
      push bx
      push dx
      push es
      in al,60h   ;从60H端口获取扫描码
      pushf
      pushf
      pop bx
      and bh,11111100b
      push bx
      popf
      call dword ptr ds:[0]   ;调用原int9中断s

      mov bl, al ;保存al

piMAIN:      ;按下或松开事件处理主要内容
piJUDGE0:
      cmp al,01H  ;判断是否按下esc  esc的扫描码是01H  按下esc结束程序
      jnz piJUDGE1
      jmp piEXIT
piJUDGE1:     ;判断是否为按下SHIFT
      cmp al,2aH  ;2aH是SHIFT的扫描码
      jnz piJUDGE2
      mov dl,1
      mov SHIFT,dl    ;用dx记录SHIFT状态 1为按下
      jmp piEXITNEWINT9
piJUDGE2:     ;判断是否为松开SHIFT
      cmp al,0aaH  ;aaH是SHIFT的断码
      jnz piVOICE
      mov dl,0
      mov SHIFT,dl    ;用dx记录SHIFT状态 0为松开
      jmp piEXITNEWINT9
piVOICE:     
      ;cmp al,02H ; 02h是1的扫描码//
      ;在TABSCAN中查找有没有与按下的键的扫描码对应的值
      ;push dx
      push ax
      push es
      mov ax,ds
      mov es,ax   
      cld
      mov di,offset TABSCAN
      mov cx,36
      mov al,bl   ;串扫描字节(AL)-(ES:[DI])
      repne scasb
      
      jnz pirelease
      
      ;计算输入字符在tabscan中对应的偏移量
      dec di
      mov ax,di
      mov di,offset TABSCAN
      sub ax,di   ;将初步偏移量放入ax中
add picount,1
      ;检测按下字符时SHIFT的状态
      mov dl,SHIFT
      cmp dl,1
      jnz piORIGIN  ;不等于1  跳转到ORIGIN（不做升调处理）
      ;否则升调（除了其中6种情况）
      mov dl,bl   ;扫描码放入dl中
      cmp dl,04H  ;判断是不是SHIFT+3
      jz pirelease
      cmp dl,12H  ;判断是不是SHIFT+e
      jz pirelease
      cmp dl,20H  ;判断是不是SHIFT+d
      jz pirelease
      cmp dl,08H  ;判断是不是SHIFT+7
      jz pirelease
      cmp dl,16H  ;判断是不是SHIFT+u
      jz pirelease
      cmp dl,24H  ;判断是不是SHIFT+j
      jz pirelease

      ;升调处理
      inc ax

piORIGIN:
      mov di,ax
      pop es
      pop ax
      
      push ax
      push bx
      ;显示按下的键
      mov bx,di
      mov dl,TABKEY[bx]
      mov ah,2
      int 21H
      ;发声
      add bx,bx
      mov ax,0000H;           常数120000H做被除数  
      mov dx,0012H; 
      mov cx,TABVAL[bx]
      div cx;      计算频率值  

      mov dx,ax   ;              将之存入DX寄存器  
      in  al,61H
      or  al,00000011B;将0x61地址的bit0和bit1置1
      out 61H,al
      mov al,10110110B;定时器2状态3
      out 43H,al
      mov ax,dx
      out 42H,al;写高字节
      mov al,ah
      out 42H,al;写低字节，然后就响了

      pop bx
      pop ax
      
      jmp piEXITNEWINT9

pirelease:    ;释放事件
      pop es
      pop ax 
    ;add picount,1
      push ax
      
      ;停止发声
      in al,61H;             关闭与门  
      and al,0FCH;  
      out 61H,al; 
      pop ax
      jmp piEXITNEWINT9

 piEXIT:
      push ax
      mov al,1
      mov break,al
      pop ax
      jmp piEXITNEWINT9

piEXITNEWINT9:      ;结束该次响应9
    ;MOV AH,01H
    ;INT 21H
      pop es
      pop dx
      pop bx
      pop ax
      iret
piNEWINT9 endp   

WRITE PROC
    push ax
    push bx
    push cx
    push dx    
    ;设置最大字符数
    mov al,0fch ;刨除最大字符数、实际字符数数和末尾$
    mov writebuf,al
    ;设置0AH功能缓冲区首地址
    mov dx,offset writebuf
    ;调用0AH功能
    mov ah,0ah
    int 21h
    ;读取存入到缓冲区的实际字符数到bx
    mov bx,1
    mov bl,writebuf[bx]
    mov bh,0


    ; ;在字符串末尾加“$”
    ; mov al,'$'
    ; mov writebuf[bx],al


    ; 输出writebuf
    ; mov dx,offset writebuf
    ; add dx,2
    ; mov ah,9
    ; int 21h
    ;设置文件名缓冲区最大字符数

    ;此处加保存文件提示
    mov dx,offset info1
    mov ah,9
    int 21h

    mov al,61;刨除最大字符数、实际字符数数和末尾 0
    mov newfile,al
    ;设置0AH功能缓冲区首地址
    mov dx,offset newfile
    ;调用0AH功能
    mov ah,0ah
    int 21h
    ;读取存入到缓冲区的实际字符数到bx
    mov bx,1
    mov bl,newfile[bx]
    mov bh,0
    ;在字符串末尾加 0
    mov al,0
    add bx,2
    mov newfile[bx],al

    ;新建名字为file中内容的文件 返回文件代号或错误码到ax
    mov bx,offset newfile
    add bx,2
    mov dx,bx;DS:DX=数据缓冲区地址
    mov cx,0
    mov ah,3ch
    int 21h
    ;将writebuf中的内容写入刚新建的文件
    mov bx,offset writebuf
    add bx,2
    mov dx,bx;DS:DX=数据缓冲区地址
    dec bx
    mov cl,writebuf[bx];写入的字节数
    mov ch,0
    mov bx,ax;BX=文件代号
    mov ah,40h
    int 21h

    pop es
    pop dx
    pop bx
    pop ax
    RET
WRITE ENDP
MUSIC proc
    push ax
    push bx
    push cx
    push dx  
MUrestart:
    mov al,0
    mov break,al
    mov pwait,al
    CALL CLEAR
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
    CMP AL,'3'
    JE MUCHOICE2
    jmp MUrestart

MUCHOICE0:
    LEA DI,PLAY1; 乐曲1 偏移地址给DI
    CALL MUPLAY
    JMP MUrestart
MUCHOICE1:
    LEA DI,PLAY2; 乐曲2 偏移地址给DI
    CALL MUPLAY
    JMP MUrestart
MUCHOICE2:
    call readfile
    LEA DI,buf ; 乐曲2 偏移地址给DI
    CALL MUPLAY
    JMP MUrestart
MUQUIT:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

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
    jmp MUwaitin
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
    jmp MUPQUIT
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
readfile proc
        push ax
        push bx
        push cx
        push dx
        mov dx , offset file
        mov al , 0
        mov ah , 3dh
        int 21h                  ;打开文件
        jc  error                  ;若打开出错，转error
        mov handle , ax           ;保存文件号
        mov bx , ax
        mov cx , 600
        mov dx , offset buf
        mov ah , 3fh
        int 21h                  ;从文件中读600字节→buf
        jc  error                  ;若读出错，转error
        mov bx , ax              ;实际读到的字符数送入bx
        mov buf[bx] , '$'          ;在文件结束处放置一“$”符
        ;mov cx,bx
        mov DI,offset buf
readloop1:
        mov bl,[DI]
        cmp bl,'$'      
        jz close         ;到了文件末尾
        mov bl,[DI+1]
        sub bl,30H
        mov [DI+1],bl
        add DI,2
        jmp readloop1

close:
        ;mov dx , offset buf
        ;mov ah , 9
        ;int 21h                            ;显示文件内容

        mov dl,13
        mov ah,2
        int 21H
        mov dl,10
        int 21h

        mov bx , handle
        mov ah , 3eh
        int 21h                            ;关闭文件
        jnc end1             ;若关闭过程无错，转到end1处返回dos
error:
        mov dx , offset error_message
        mov ah , 9
        int 21h                            ;显示错误提示
end1:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
readfile endp

PRACTICE proc
    push ax
    push bx
    push cx
    push dx  
PRArestart:
    mov al,0
    mov break,al
    mov pwait,al
    CALL CLEAR
    LEA DX,STARTMSG;        输出提示信息,选择界面
    MOV AH,09H;
    INT 21H;
OTHER:
    MOV AH,01H;  接受按键
    INT 21H;
    CMP AL,'0';        
    JE PRAQUIT;     退出
    CMP AL,'1'
    JE PRACHOICE0
    CMP AL,'2'
    JE PRACHOICE1
    CMP AL,'3'
    JE PRACHOICE2
    JMP PRArestart
PRACHOICE0:
    LEA DI,PLAY1; 涔愭洸1 鍋忕Щ鍦板潃缁橠I
    CALL PRAPLAY
    JMP PRArestart
PRACHOICE1:
    LEA DI,PLAY2; 涔愭洸2 鍋忕Щ鍦板潃缁橠I
    CALL PRAPLAY
    JMP PRArestart
PRACHOICE2:
    call readfile
    LEA DI,buf; 涔愭洸2 鍋忕Щ鍦板潃缁橠I
    CALL PRAPLAY
    JMP PRArestart
PRAQUIT:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

PRAPLAY proc
    
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

    CALL CLEAR
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
    jmp PRAPQUIT
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
code ENDS
    END start