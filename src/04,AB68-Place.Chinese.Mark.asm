; ROM 位置: 012B78 (04:AB68)

; 原始函数: LoadNextChar
; LoadNextChar (01180D / 04:97FD):     JMP AB68
.org $AB68

; LoadNextChar
; 04,AB68

; byte[0043] 等待帧数, 如果不是 0 则跳出
DEC $0043
BNE _END
LDA #$08
STA $0043

; byte [0046] = 当前对话文字指针偏移
LDA $0046
ASL           ; Shift left
TAY

; WORD [9848] = 对话文字指针
LDA $9848,Y       ; WORD: 0x4E 0x98 (984E)
STA $0002       ;
LDA $9849,Y       ;
STA $0003       ;

; byte [0047] = 当前对话文字偏移
LDY $0047       ; Y = [0047] (01)
INC $0047       ; [0047]++
LDA ($02),Y       ; A = _THE_CHR

; 控制符检测
CMP #$FF
BEQ _END_WITH_CARRY
  CMP #$FE
  BNE _SKIP_LINE_BREAK
    ; 换行符号
    INC $0048   ; Y Position?

    JSR _UpdatePosition

  _READ_NEXT_CHAR:
    LDY $0047
    INC $0047
    LDA ($02),Y
    jmp _END_CONTROL_CHAR

  _SKIP_LINE_BREAK:
    CMP #$FD
    BNE _SKIP_ENABLE_CHINESE
      LDA #$01
      STA $07EE
      jmp _READ_NEXT_CHAR


  _SKIP_ENABLE_CHINESE:
  _END_CONTROL_CHAR:
  STA $0008
  CMP #$00
  BEQ _SKIP_NO_SOUND
    AND #$C0
    CMP #$C0
    BEQ _SKIP_NO_SOUND
      LDA #$0E
      JSR $F9BC

  _SKIP_NO_SOUND:

  JSR PutNextDialogChar

  ; 因为是中文, 到时候看情况是否需要加延迟。
  ;LDA $0008
  ;BPL _END
  LDA #$0C
  STA $0043

_END:
  CLC
  RTS
_END_WITH_CARRY:
  ; 清空中文标记
  LDA #$00
  STA $07EE
  SEC
  RTS


PutNextDialogChar:
  LDX $0021   ; X = [0021]; Offset, usually 0x00.

  ; 写出信息标记?
  LDA #$01    ; A = 0x01
  STA $0700,X   ; [0700] = 0x01

  ; 写出位置
  LDA $004A   ; A = [004A]
  STA $0701,X   ; [0701] = A

  LDA $0049   ; A = [0049]
  STA $0702,X   ; [0702] = A


  ; LDY $0047   ; 还原当前对话的偏移

  ; Loop - 检查中文字符
_Loop_SearchForChinese:
  LDA ($02),Y   ; A = 当前字符
  AND #$C0    ; 检查第一位是不是 1
  CMP #$C0    ; 中文控制符
  BNE _END_CHINESE; 跳过中文字符处理

  ; 是中文控制符
  ; 加入两个字符，并，自循环
  ; 写出 2 个控制符
  TXA       ; 
  PHA       ; push X

  LDA ($02),Y   ; A = ChineseCtrlChar
  AND #$7     ; 
  TAX       ; X = A
  INY       ; Y++
  ; 此时的 stack: X
  ; 此时的值: X = PPU 序号
  ;           Y = 正常的序号

  LDA ($02),Y   ; A = NextChar
  STA $07F0,X   ; [07FX] = A (CHR_BANK_X)
  INY       ; Y++

  PLA
  TAX       ; pop X

  STY $0047   ; 储存对话偏移
  INC $0047

  JSR $FACE

  JMP _Loop_SearchForChinese

_END_CHINESE:
  LDA ($02),Y
  STA $0703,X   ; [0704] = A

  LDA #$FF    ; A = __END_MARK__
  STA $0704,X   ; [0705] = A

  TXA       ; A = X
  CLC       ; Clear Carry

  ADC #$05    ; Add 06 to A
  STA $0021   ; [0021] = A

  INC $0049   ; [0049]++

  RTS







_UpdatePosition:
  ; 读取下一行的位置的偏移地址
  LDA $0046
  ASL
  TAY
  LDA $97DB,Y
  STA $0000
  LDA $97DC,Y
  STA $0001

  ; 写出 PPU 定位地址
  LDA $0048
  ASL

  TAY
  LDA ($00),Y
  STA $0049
  INY
  LDA ($00),Y
  STA $004A
  RTS
