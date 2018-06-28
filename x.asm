DATA SEGMENT
      INPROG DW 2 DUP(?)
      TABVAL   DW  262,277,294,311,330,349,370,392,415,440,466,494
               DW  523,554,587,622,659,698,740,784,831,880,932,988
               DW  1046,1109,1175,1245,1318,1397,1480,1568,1661,1760,1865,1976
      TABKEY   DB  '1','!','2','@','3','4','$','5','%','6','^','7' 
               DB  'q','Q','w','W','e','r','R','t','T','y','Y','u'
               DB  'a','A','s','S','d','f','F','g','G','h','H','j'
      ; TABSCAN  DB  02H,'!',03H,'@',04H,05H,'$',06H,'%',07H,'^',08H
      ;          DB  10H,'Q',11H,12H,'E',13H,'R',14H,'T',15H,'Y',16H
      ;          DB  1eH,'A',1fH,20H,'D',21H,'F',22H,'G',23H,'H',24H
      TABSCAN  DB  02H,02H,03H,03H,04H,05H,05H,06H,06H,07H,07H,08H
               DB  10H,10H,11H,11H,12H,13H,13H,14H,14H,15H,15H,16H
               DB  1eH,1eH,1fH,1fH,20H,21H,21H,22H,22H,23H,23H,24H
      SHIFT       DB  00H
DATA ENDS

CODE SEGMENT
      ASSUME CS:CODE,DS:DATA

START:

      mov ax,DATA
      mov ds,ax
piano proc
      push ax
      push bx
      push cx
      push dx
     ; 改中断例程入口地址
      mov ax,0
      mov es,ax
      push es:[9*4]
      pop ds:[0]
      push es:[9*4+2]
      pop ds:[2]
      mov word ptr es:[9*4],offset piNEWINT9
      mov es:[9*4+2],cs
piLOOPMAIN:
      jmp piLOOPMAIN   ;死循环，等待中断到来

; 定义中断例程
piNEWINT9:
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
      cmp al,0bH  ;判断是否按下0  0的扫描码是0bH  按下0结束程序
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
      
      push ax
      
      ;停止发声
      in al,61H;             关闭与门  
      and al,0FCH;  
      out 61H,al; 
      pop ax
      jmp piEXITNEWINT9

 piEXIT:
      ; cmp bl, 0bh ;4Fh是EXIT键的扫描码;0bh是0的扫描码
      ; jne piEXITNEWINT9
      ;处理EXIT，使程序结束，注意在此要恢复中断向量
      mov ax,0
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

piEXITNEWINT9:      ;结束该次响应9
      pop es
      pop dx
      pop bx
      pop ax
      iret
piano endp

CODE ENDS
    END START