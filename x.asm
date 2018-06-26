DATA SEGMENT
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
               DB  10H,10H,11H,12H,12H,13H,13H,14H,14H,15H,15H,16H
               DB  1eH,1eH,1fH,20H,20H,21H,21H,22H,22H,23H,23H,24H
DATA ENDS

CODE SEGMENT
      ASSUME CS:CODE,DS:DATA

START:
      mov ax,DATA
      mov ds,ax

     ; 改中断例程入口地址
      mov ax,0
      mov es,ax
      push es:[9*4]
      pop ds:[0]
      push es:[9*4+2]
      pop ds:[2]
      mov word ptr es:[9*4],offset int9
      mov es:[9*4+2],cs
loopMain:
      jmp loopMain   ;死循环，等待中断到来

; 定义中断例程
int9:
      push ax
      push bx
      push dx
      push es
      in al,60h
      pushf
      pushf
      pop bx
      and bh,11111100b
      push bx
      popf
      call dword ptr ds:[0]

      mov bl, al ;保存al
press:      ;按下事件  
      ; push ax
      ; ;显示按下的字符
      ; mov di,dx
      ; mov dl,TABKEY[di]
      ; mov ah,2
      ; int 21H
      
      ; pop ax
      ; ;显示按下的键的扫描码
      ; mov dl,ah;
      ; push ax
      ; mov ah,2
      ; int 21H
      ; pop ax

      ;显示按下的扫描码
      push ax
      mov dl,al
      mov ah,2
      int 21H
      pop ax

      ; cmp al,2aH  ;2aH是shift的扫描码
      ; jnz VOICE
      ; mov dx,1    ;用dx记录shift状态 1为按下

VOICE:     
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
      
      jnz release
      
      dec di
      mov ax,di
      mov di,offset TABSCAN
      sub ax,di

      ;输入字符在tabscan中对应的偏移量
      ; push ax
      ; add al,30H
      ; mov dl,al
      ; mov ah,2
      ; int 21H
      ; pop ax

      ; push ax
      ; add ah,30H
      ; mov dl,ah
      ; mov ah,2
      ; int 21H
      ; pop ax
      ;输入字符在tabscan中对应的偏移量



      mov di,ax
      ;add di,di
      ;mov dx,di   ;用dx暂存频率表TABVAL的偏移量
      pop es
      pop ax
      ;pop dx
      ;jne release
      
      push ax
      
      
      ;发声
      add di,di
      mov ax,0000H;           常数120000H做被除数  
      mov dx,0012H; 
      mov cx,TABVAL[di]
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

      
     
      pop ax
      jmp int9ret

release:    ;释放事件
      pop es
      pop ax 

      ; cmp al,82h ; 82h是1的断码
      ; jne press_end
      
      push ax
      
      ;停止发声
      in al,61H;             关闭与门  
      and al,0FCH;  
      out 61H,al; 


      pop ax
      jmp int9ret

 press_end:
      cmp bl, 0bh ;4Fh是end键的扫描码;0bh是0的扫描码
      jne int9ret
      ;处理END，使程序结束，注意在此要恢复中断向量
      mov ax,0
      mov es,ax

      push ds:[0]
      pop es:[9*4]
      push ds:[2]
      pop es:[9*4+2]

      mov ax,4c00h
      int 21h

int9ret:pop es
      pop dx
      pop bx
      pop ax
      iret

CODE ENDS
    END START