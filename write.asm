data segment
    writebuf db 260 dup(?);用来存写入的内容
    newfile  db 64  dup(?);用来存文件名
    info1    db 'input file name:$'
    ee db 'aaaa.txt'
data ends

code  segment
    assume cs:code,ds:data
start:
    mov ax,data
    mov ds,ax
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

    mov al,61;刨除最大字符数、实际字符数数和末尾$
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
    ;在字符串末尾加“$”
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



    mov ah,4ch
    int 21h
code ends
    end start