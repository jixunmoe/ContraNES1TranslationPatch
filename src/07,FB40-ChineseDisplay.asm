; 07,FB40: 01FB50
; STA $2007

.org $FB40
; A = THE VALUE
; 检查是否为中文字符

PHA       ; push A
AND #$C0
CMP #$80
BNE _NOT_CHINESE

; 检查中文 flag
LDA $07EE
CMP #$00
BEQ _NOT_CHINESE

; 中文字符!
PLA       ; pop A


; 获取字符信息
ASL
ASL

; A = Tile ID
; 写出左上角
STA $2007
ADC #$1

; 写出右上角
STA $2007
ADC #$1

PHA

LDA $07EE
CMP #$01
BEQ _TYPE_01
CMP #$02
BEQ _TYPE_02
CMP #$03
BEQ _TYPE_03

JMP _NOT_CHINESE


_NOT_CHINESE:
  PLA     ; pop A

_DISPLAY:
  STA $2007
_EXIT:
  ; JMP $CB9E
  RTS


_TYPE_01_JMP:
  ; JMP _TYPE_01

_TYPE_02_JMP:
  ; JMP _TYPE_02


_TYPE_01:
  ; 寻找左下角的坐标
  LDA $0049 ; A = LOW_ADDR
  CLC
  ADC #$1F

  LDA $004A
  ADC #$00
  STA $2006 ; Write Hi Part.

  CLC
  LDA $0049
  ADC #$1F
  STA $2006 ; Write Lo Part.
  CLC

  INC $0049 ; 跳过写出了的位置

  PLA     ; pop A

  STA $2007
  ADC #$1

  JMP _DISPLAY



_TYPE_02:
  ; 寻找左下角的坐标
  LDA $004A ; A = LOW_ADDR
  CLC
  ADC #$1F

  LDA $004B
  ADC #$00
  STA $2006 ; Write Hi Part.

  CLC
  LDA $004A
  ADC #$1F
  STA $2006 ; Write Lo Part.
  CLC

  INC $004A ; 跳过写出了的位置

  PLA     ; pop A

  STA $2007
  ADC #$1

  JMP _DISPLAY


_TYPE_03:
  ; 寻找左下角的坐标
  LDA $0043 ; A = LOW_ADDR
  CLC
  ADC #$1F

  LDA $0044 ; HI ADDR
  ADC #$00
  STA $2006 ; Write Hi Part.

  CLC
  LDA $0043
  ADC #$1F
  STA $2006 ; Write Lo Part.
  CLC

  INC $0043 ; 跳过写出了的位置

  PLA     ; pop A

  STA $2007
  ADC #$1

  JMP _DISPLAY

