;  04:AF60:FF        UNDEFINED
;   012F70:FF        UNDEFINED

.org $AF60
LoadNextEndingChar:
	LDA #$00
	STA $0023

	; 拷贝字符串地址
	LDA $855B,Y
	STA $0000
	LDA $855C,Y
	STA $0001


	; Y = 读取的字符偏移
_GET_NEXT_CHAR:
	LDY $0042
	INC $0042
	LDA ($00),Y
	BEQ _SED_EXIT

	CMP #$FB
	BNE _SKIP_SET_WAIT
		LDA #$01
		STA $001A
		RTS


_SKIP_SET_WAIT:
	CMP #$FF
		BEQ _EXIT_FINISH_DIALOG
	CMP #$FE
		BEQ _NEW_LINE

    CMP #$FD
    BNE _SKIP_ENABLE_CHINESE
      LDA #$03
      STA $07EE
      ; Read next char
      JMP _GET_NEXT_CHAR

  _SKIP_ENABLE_CHINESE:

  ; Loop - 检查中文字符
_Loop_SearchForChinese:
  LDA ($00),Y   ; A = 当前字符
  AND #$C0    ; 检查第一位是不是 1
  CMP #$C0    ; 中文控制符
  BNE _END_CHINESE; 跳过中文字符处理

  ; 是中文控制符
  ; 加入两个字符，并，自循环
  ; 写出 2 个控制符
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

  STY $0042   ; 储存对话偏移
  INC $0042

  JSR $FACE

  JMP _Loop_SearchForChinese


_END_CHINESE:
	LDX $0021
	LDA #$01
	STA $0700,X

	; 检查是否为中文字符.
	AND #$C0
	CMP #$80
	BEQ _ADD_CHINESE
		JMP _END_ADD_CHAR
_ADD_CHINESE:
	; 定位
	; LO ADDR
	LDA $0043
	STA $0702,X
	CLC
	ADC #$20
	STA $0708,X

	; HI ADDR
	LDA $0044
	STA $0701,X

	ADC #$00
	STA $0707

	; 写出第一个贴图块
	LDA ($00),Y
	STA $0703,X

	; 写出后续贴图块
	CLC
	ADC #$01
	STA $0704,X

	CLC
	ADC #$01
	STA $0709,X

	CLC
	ADC #$01
	STA $070A,X

	; 写出终止符
	LDA #$FF
	STA $0705,X
	STA $070B,X

	INC $0043

	TXA
	CLC
	ADC #$0C		; 下次写出的偏移
	STA $0021
	LDA #$10
	JSR $F9BC		; Play sound

_SED_EXIT:
	INC $0043
_EXIT:
	RTS

_EXIT_FINISH_DIALOG:
	LDA #$00
    STA $07EE
	LDA #$FF
	RTS

_NEW_LINE:
	; 0043:
	LDA $0043
	AND #$E0
	STA $0043

	; [0043] = [0043] + #$45
	LDA #$43	; Position next line; Original Value #$45
	LDX #$43
	JSR _C72D
	LDA #$01
	RTS

_C72D:
	CLC
	ADC $00,X
	STA $00,X
	BCC _C736
		INC $01,X
_C736:
	RTS
