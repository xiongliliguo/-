DATA SEGMENT
  OLD          DW    0,0
  PLAY_STACK   DB    256 DUP('$')
  POINT        DB    0
  SAVE_COUNT   DB    0
  PLAY_COUNT   DB    0
  RATETABLE    DW    524,588,660,698,784,880,988,1048   ;Ƶ�ʱ�  
  STARTMSG     DB    'Welcome  in ',0ah,0dh          ;��ʾ��Ϣ              
               DB    '1.Practice',0ah,0dh,
               DB    '2.Play',0ah,0dh,
               DB    '3.Open/Write',0ah,0dh
               DB    '0.Quit:',0ah,0dh,'$'
  PROC1MSG     DB    'This is Proc1',0ah,0dh,'$' 
  PROC2MSG     DB    'This is Proc2',0ah,0dh,'$'
  PROC3MSG     DB    'This is Proc3',0ah,0dh,'$' 
  EXAMPLAY1    DB    '1 2.3 4^|4 3.2.1.|1^2^3^4.|4 3 2 1 |1 2 3 4 ',0AH,0DH,'$'
DATA ENDS  
  
SSTACK SEGMENT STACK  
          DW    100 DUP(?)  
SSTACK ENDS  
  
CODE SEGMENT  
  ASSUME CS:CODE,DS:DATA  




COMP PROC  
  T:               ;����'|'����(INCCL)�����(POINT)
    MOV BH,0 
    LEA DI,EXAMPLAY1
    MOV AX,DI[BX]
    CMP AL,'|'
    JE INCCLI
    JMP COMPE
  INCCLI:
    INC BL
    PUSH DX
    PUSH AX
    MOV DL,'|';
    MOV AX,02H
    INT 21H
    MOV POINT,BL
    POP AX
    POP DX
    JMP T 
COMPE: 
  PUSH DX
  PUSH CX
  PUSH BX
  PUSH AX
  PUSH DI
  MOV BH,00H
  MOV BL,POINT
  LEA DI,EXAMPLAY1
  MOV CX,DI[BX]
  MOV DL,CH  ;���
  MOV AH,02H
  INT 21H
  MOV DL,CL
  INT 21H
  MOV BL,PLAY_COUNT
  LEA DI,BYTE PTR PLAY_STACK
  MOV AL,DI[BX]
  
  JE CON
  JMP ERROR
  CON:
    PUSH BX;  
    PUSH AX;   
    PUSH DX;
    ;д�ж�
    CALL DELAY

    POP DX
    POP AX
    POP BX
    INC BL
    MOV PLAY_COUNT ,BL
    MOV BL,POINT
    INC BL
    MOV POINT,BL
    
  ERROR:
    CALL DELAY
  POP DI
  POP AX
  POP BX
  POP CX
  POP DX
  IRET
COMP ENDP



CLEAR PROC;����
  MOV AH,00H
  MOV AL,03H
  INT 10H
  RET
CLEAR ENDP

NEWINT9 PROC;��9�ж�,��ȡ60��ֵ����stack,����save_count+1
  PUSH AX
  PUSH BX
  PUSH DX
  PUSH ES
  IN AL,60H
  PUSHF
  MOV ES,OLD
  MOV BX,OLD[2]
  CALL DWORD PTR ES:BX
  POPF
  POP ES
  CMP AL,03H
  JE START
  MOV BH,00H
  MOV BL,PLAY_COUNT
  MOV PLAY_STACK[BX],AL
  INC BL
  MOV PLAY_COUNT,BL

  MOV DL,AL
  MOV AH,02H
  INT 21H

  POP DX
  POP BX
  POP AX
  IRET
NEWINT9 ENDP

SETINT9 PROC;����9�ж�
  MOV AX,3509H
  INT 21H
  PUSH ES
  PUSH BX
  PUSH DS
  MOV DX,OFFSET NEWINT9
  MOV AX,SEG NEWINT9
  MOV DS,AX
  MOV AX,2509H
  INT 21H
  POP DS
  ;IN AL,21H
  ;AND AL,11111110B
  ;OUT 21H,AL
  MOV OLD,ES
  MOV OLD[2],BX
  POP BX
  POP ES
  STI
  RET
SETINT9 ENDP

RESETINT9 PROC
  PUSH DS
  PUSH DX
  MOV DX,OLD[2]
  MOV DS,OLD
  MOV AX,2509H
  INT 21H
  POP DX
  POP DS
  RET
RESETINT9 ENDP

START:  
  MOV AX,DATA;  
  MOV DS,AX;  
  CALL FAR PTR CLEAR
  LEA DX,STARTMSG;        �����ʾ��Ϣ  
  MOV AH,09H;  
  INT 21H;  
  
;ѡ�����
INPUT:  
  MOV AH,01H;  
  INT 21H;  

  CMP AL,'0';        
  JE FAR PTR QUIT;     �˳�
  CMP AL,'1'
  JE FAR PTR PROC1;    ��ϰ
  CMP AL,'2'
  JE FAR PTR PROC2;    �Զ�����
  CMP AL,'3'
  JE FAR PTR PROC3;    �༭

DELETE:  
  MOV AH,03H;  �����ˣ��ÿո��滻���ٻ���
  INT 10H
  MOV AH,02H
  DEC DL
  INT 10H
  PUSH DX
  MOV DL,20H;
  INT 21H
  POP DX
  INT 10H  
  JMP INPUT
    
PROC1:;��ϰ
  CALL CLEAR
  LEA DX,PROC1MSG;        ��ʼ��  
  MOV AH,09H;  
  INT 21H;
  MOV AL,0
  MOV PLAY_COUNT,AL
  MOV SAVE_COUNT,AL
  CALL SETINT9
  LEA DX,EXAMPLAY1 ; �����������
  MOV AH,09H
  INT 21H
  LEA DX,EXAMPLAY1
  READKEY:
    MOV BL,PLAY_COUNT
    CMP BL,SAVE_COUNT
    JL JCOMP
    JMP READKEY
  CALL RESETINT9
  JMP START

JCOMP:
  CALL COMP
  JMP READKEY

PROC2 :;�Զ�����
  CALL CLEAR
  LEA DX,PROC2MSG;        �����ʾ��Ϣ  
  MOV AH,09H;  
  INT 21H;
  CALL SETINT9

    
  
  JMP START

PROC3 :;�༭
  CALL CLEAR
  LEA DX,PROC3MSG;        �����ʾ��Ϣ  
  MOV AH,09H;  
  INT 21H;


  JMP START

;�˳�����  
QUIT:  
  MOV AH,4CH;  
  INT 21H;  
   
 ;�ӳ�������PIANOFUC  
 ;���ܣ�    ��AL�Ĵ������ַ�1��2��3��4��5��6��7��i��ASCII��Ϊ����  
 ;          ��Ƶ�ʱ�(RATETABLE),ʹ������������ͬƵ�ʵ�����  
 PIANOFUC PROC  
  PUSH BX;  
  PUSH AX;   
  PUSH DX;  
  
  CMP AL,'1'   
  JZ ONE  
    
  CMP AL,'2'  
  JZ TWO  
    
  CMP AL,'3'  
  JZ THREE  
    
  CMP AL,'4'  
  JZ FOUR  
    
  CMP AL,'5'  
  JZ FIVE  
    
  CMP AL,'6'  
  JZ SIX  
    
  CMP AL,'7'  
  JZ SEVEN  
    
  CMP AL,'8'  
  JZ EIGHT  
    
  JMP QUIT_PIANOFUC  
ONE:  
  MOV BX,0  
  JMP OUT_VOI  
TWO:  
  MOV BX,2  
  JMP OUT_VOI  
THREE:  
  MOV BX,4  
  JMP OUT_VOI  
FOUR:  
  MOV BX,6  
  JMP OUT_VOI  
FIVE:  
  MOV BX,8  
  JMP OUT_VOI  
SIX:  
  MOV BX,10  
  JMP OUT_VOI  
SEVEN:  
  MOV BX,12  
  JMP OUT_VOI  
EIGHT:  
  MOV BX,14   
     
OUT_VOI:   
    
  MOV AX,0000H;           ����120000H��������  
  MOV DX,0012H;  
    
  DIV RATETABLE[BX];      ����Ƶ��ֵ  
  MOV BX,AX;              ��֮����BX�Ĵ���  
    
  MOV AL,10110110B;       ���ö�ʱ��������ʽ  
  OUT 43H,AL  
    
  MOV AX,BX;                
  OUT 42H,AL;             ���õ�λ  
    
  MOV AL,AH;              ���ø�λ  
  OUT 42H,AL  
    
  IN AL,61H;             ������  
  OR AL,03H;  
  OUT 61H,AL  
    
  CALL DELAY  
    
  IN AL,61H;             �ر�����  
  AND AL,0FCH;  
  OUT 61H,AL;  
  
;�˳�����  
QUIT_PIANOFUC:        
  POP DX  
  POP AX  
  POP BX;   
  RET  
 PIANOFUC ENDP  
   
   
   
   
;�ӳ�������DELAY  
;���ܣ�    �ӳ�һ��ʱ��  
 DELAY  PROC  
  PUSH CX  
  
  MOV CX,03H;  
DELAYLOOP1:   
  PUSH CX;  
    
  MOV CX,0FFFFH  
DELAYLOOP2:
  PUSH AX;
  POP AX  
  LOOP DELAYLOOP2  
    
  POP CX;  
  LOOP DELAYLOOP1  
    
  POP CX  
  RET  
 DELAY ENDP  
   
   
CODE ENDS
 
     END START 