; JSR $9034

;  012DD0:FF        UNDEFINED
; 04:ADC0:FF        UNDEFINED
.org $ADC0

LDA $0008
AND #$40
BEQ _2x2_LETTER           ; 如果是大字就跳 (24x24)

_LARGE_LETTER:
  LDA $0008
  CLC
  SBC #$40
  ; 后面的代码没改过
  JMP $90A0

_2x2_LETTER:
  LDA $0008
  ASL     ; A <<= 2 (字符 * 4)
  ASL
  AND #$7F
  TAY     ; Y = A

  ; A = (a * 4 overflow) ? 20 : 0
  ; Offset = A
  LDA $0008 ; A = [0008]
  AND #$20  ; 20 表示写出位置 + 20
  CLC

  ; 坐标~
  ADC $0042
  STA $0000

  LDA #$00
  ADC $0043
  STA $0001

  ; Load x offset.
  LDX $0021
  LDA #$01
  STA $0700,X
  STA $0706,X

  ; 写出坐标
  LDA $0000
  STA $0702,X
  CLC

  ADC #$20
  STA $0708,X

  LDA $0001
  STA $0701,X

  ADC #$00
  STA $0707,X

  LDA _TITLE_CHAR_TABLE + 0, Y
  STA $0703,X

  LDA _TITLE_CHAR_TABLE + 1, Y
  STA $0704,X

  LDA _TITLE_CHAR_TABLE + 2, Y
  STA $0709,X

  LDA _TITLE_CHAR_TABLE + 3, Y
  STA $070A,X

  LDA #$FF
  STA $0705,X
  STA $070B,X

  TXA     ; A = X
  CLC
  ADC #$0C  ; A += 0x0C
  STA $0021 ; Write x-offset

  ; 向右移动两个字节
  LDA $0042
  CLC
  ADC #$02
  STA $0042

  RTS

_TITLE_CHAR_TABLE:
  .byte $0,$1,$10,$11
  .byte $2,$3,$12,$13
  .byte $4,$5,$14,$15
  .byte $6,$7,$16,$17
  .byte $8,$9,$18,$19
  .byte $a,$b,$1a,$1b
  .byte $c,$d,$1c,$1d
  .byte $e,$f,$1e,$1f
  .byte $20,$21,$30,$31
  .byte $22,$23,$32,$33
  .byte $24,$25,$34,$35
  .byte $26,$27,$36,$37
  .byte $28,$29,$38,$39
  .byte $2a,$2b,$3a,$3b

  ; 前引号
  ; .byte $2c,$2d,$3c,$3d
  .byte $0B,$00,$00,$00

  ; 逗号
  ; .byte $2e,$2f,$3e,$3f
  .byte $00,$00,$1B,$00

  ; 句号 (10)
  ; .byte $40,$41,$50,$51
  .byte $00,$00,$0A,$00

  ; 之 (11)
  .byte $F7,$F8,$F9,$FA

  ; 名
  .byte $FB,$FC,$FD,$FE

  .byte $46,$47,$56,$57
  .byte $48,$49,$58,$59
  .byte $4a,$4b,$5a,$5b
  .byte $4c,$4d,$5c,$5d
  .byte $4e,$4f,$5e,$5f
  .byte $60,$61,$70,$71
  .byte $62,$63,$72,$73
  .byte $64,$65,$74,$75
  .byte $66,$67,$76,$77
  .byte $68,$69,$78,$79
  .byte $6a,$6b,$7a,$7b
  .byte $6c,$6d,$7c,$7d
  .byte $6e,$6f,$7e,$7f
