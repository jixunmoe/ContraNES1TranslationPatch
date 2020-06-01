; From A165
;  012C70:FF        UNDEFINED
; 04:AC60:FF        UNDEFINED
PlaceNextDialogPassChar:
.org $AC60
  DEC $0047
  BEQ _DO_PROC

_EXIT_WITH_CARRY:
  CLC
  RTS

_DO_PROC:
  LDA #$06    ; A = 06
  STA $0047   ; [0047] = 06


  LDA $0030   ; A = [0030]
  ASL       ; A <<= 1
  TAY       ; Y = A

  LDA $A1D6,Y   ;
  STA $0000   ;

  LDA $A1D7,Y   ;
  STA $0001   ;

  LDY $0046   ; Y = [0046]
  LDA ($00),Y   ; 读取下一个要打印的字符
  CMP #$FF    ; 如果是结束符, 跳走
  BNE _CONTINUE_EXECUTE
    LDA #$00
    STA $07EE
    SEC
    RTS

_CONTINUE_EXECUTE:

  STA $0008 ; [0008] = A
  CMP #$FE
  BNE _SKIP_LINE_BREAK
    INY
    JSR _NEXT_LINE
    JMP _END_OF_CONTROL_CHAR

_SKIP_LINE_BREAK:
  CMP #$FD
  BNE _SKIP_ENABLE_CHINESE
    LDA #$02
    STA $07EE
  _LOAD_NEXT_CHAR:
    INY
    INC $0046
    JMP _END_OF_CONTROL_CHAR

_SKIP_ENABLE_CHINESE:
  CMP #$FC
  BNE _SKIP_CLEAR_SCREEN
    JSR _CLEAR_DIALOG

    LDA #$20        ; TODO: 清屏后的等待时间

  _SET_TIMER_AND_EXIT_WITH_CARRY:
    STA $0047
    INC $0046
    JMP _EXIT_WITH_CARRY

_SKIP_CLEAR_SCREEN:
  CMP #$FB
  BNE _SKIP_WAIT_TIMER
    LDA #$80        ; TODO: 清屏后的等待时间
    JMP _SET_TIMER_AND_EXIT_WITH_CARRY

_SKIP_WAIT_TIMER:
_END_OF_CONTROL_CHAR:

  LDX $0021   ; X = [0021]

  LDA #$01    ; 需要写出文字标记
  STA $0700,X

  LDA $004B   ; 写出位置
  STA $0701,X
  LDA $004A
  STA $0702,X


  ; Loop - 检查中文字符
_Loop_SearchForChinese:
  LDA ($00),Y   ; A = 当前字符
  AND #$C0    ; 检查第一位是不是 1
  CMP #$C0    ; 中文控制符
  BNE _END_CHINESE; 跳过中文字符处理

  ; 是中文控制符
  ; 加入两个字符，并，自循环
  ; 写出 2 个控制符
  TXA       ;
  PHA       ; push X

  LDA ($00),Y   ; A = ChineseCtrlChar
  AND #$7     ;
  TAX       ; X = A
  INY       ; Y++
  ; 此时的 stack: X
  ; 此时的值: X = PPU 序号
  ;           Y = 正常的序号

  LDA ($00),Y   ; A = NextChar
  STA $07F0,X   ; [07FX] = A (CHR_BANK_X)
  INY       ; Y++

  PLA
  TAX       ; pop X

  STY $0046   ; 储存对话偏移
  INC $0046

  JSR $FACE

  JMP _Loop_SearchForChinese

_END_CHINESE:
  LDA ($00),Y   ; 写出需要处理的字符
  STA $0703,X


  BEQ _SKIP_NO_SOUND    ; if char == 0 jump
    AND #$C0
    CMP #$C0
    BEQ _SKIP_NO_SOUND
      LDA #$10    ; Play sound
      JSR $F9BC

_SKIP_NO_SOUND:
  LDA #$FF
  STA $0704,X   ; 结束符号

  TXA       ; A = X
  CLC
  ADC #$05
  STA $0021

  INY
  STY $0046   ; 储存下一个偏移

  INC $004A
  LDA $0008

_EXIT:
  CLC
  RTS

; 清空屏幕字符
_CLEAR_DIALOG:
  JSR _RESET_POSITION

  ; 清除八行
  LDA #$10

; 循环八次
_LOOP_CLEAR:
  PHA
  JSR _ERASE_LINE
  PLA
  CLC
  SBC #$01
  BNE _LOOP_CLEAR

  ; 循环结束, 清理现场
  JSR _RESET_POSITION
  RTS


_ERASE_LINE:
  LDA #$10

_ERASE_NEXT_CHAR:
  LDY #$00

  STY $2007
  CLC

  STY $2007
  CLC

  STY $2007
  CLC

  STY $2007
  CLC

  STY $2007
  CLC

  STY $2007
  CLC

  STY $2007
  CLC

  CLC

  SBC #$01
  BNE _ERASE_NEXT_CHAR

  JSR _NEXT_LINE_8px
  RTS

_NEXT_LINE:
  ; 低位
  CLC
  LDA $0048
  ADC #$40
  STA $0048
  STA $004A

  ; 高位
  LDA $0049
  ADC #$00
  STA $0049
  STA $004B

  ; 设定等待, 不需要

  ; LDA #$30
  ; STA $0047
  RTS

; This will destory ACC register.
_RESET_POSITION:
  ; HI LO
  ; 21 11
  ;    ** [0048, 004A]
  ; **    [0049, 004B]

  LDA #$21
  STA $0049
  STA $004B
  STA $2006

  LDA #$11
  STA $0048
  STA $004A
  STA $2006

  RTS

_NEXT_LINE_8px:
  ; 低位
  CLC
  LDA $0048   ; Add new line
  ADC #$20
  STA $0048
  STA $004A

  ; 高位
  LDA $0049
  ADC #$00
  STA $0049
  STA $004B
  STA $2006

  ; 写低位地址
  LDA $0048
  STA $2006

  RTS
