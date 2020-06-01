.org $AB70
.require "Contra.inc.s"
; --------------------------
; 内存地址            04:AB70
; 文件地址             012B80
; --------------------------



; BEGIN Functions --------------------------------------------------------------
; 每一条函数占用 3 个字节

; From:   01180D / 04:97FD
; Target:          04:AB70
_Prologue_Dialog:
  JMP PrologueDialog

; From:   011044 / 04:9034
; Target:          04:AB73
_Contra_Intro:
  JMP ContraIntro

; From:   012175 / 04:A165
; Target:          04:AB76
_Level_Clear_Dialog:
  JMP LevelClearDialog

; From:   010515 / 04:8505
; Target:          04:AB79
_Screct_Ending:
  JMP ScrectEnding

; END Functions ----------------------------------------------------------------



; BEGIN G_UpdatePPU ------------------------------------------------------------
; 输入:
;   * Y: 当前偏移
; 更改:
;   * X: BANK 序号
;   * Y: 下一个字符的偏移
;   * A: 下一个字符
; 清理:
;   * STY YOUR_OFFSET
;   * INC YOUR_OFFSET
G_UpdatePPU:
  ; 开始读后面的数据
  ; 获取下一个字符: LDA ($00), Y
  ; 修复偏移 INC LCD_TEXT_OFFSET

_G_UPDATEPPU_CHECK_NEXT_CHAR:
  INY
  LDA (DIALOG_ADDR), Y
  AND #CHS_CTRL_MASK
  CMP #CHS_CTRL_FLAG
  BNE _G_UPDATEPPU_END_CTRL
    LDA (DIALOG_ADDR), Y
    AND #$07
    TAX           ; X = BANK

    INY
    LDA (DIALOG_ADDR), Y
    STA CHR_BANK_BASE, X
    JMP _G_UPDATEPPU_CHECK_NEXT_CHAR

_G_UPDATEPPU_END_CTRL:
  LDA (DIALOG_ADDR), Y
  RTS

; END G_UpdatePPU --------------------------------------------------------------



; BEGIN G_DisplayCharacter -----------------------------------------------------
; 输出一个字符到图案输出缓冲区 (稍后在 NMI 函数显示到屏幕)
; 输入: A = 需要显示的字符
; 影响: A = 乱码
G_DisplayCharacter:
  LDX PPU_BUFF_OFFSET
  PHA

  AND #CHS_CHAR_MASK
  CMP #CHS_CHAR_FLAG
  BEQ _DISPLAY_CHINESE_CHR
    ; 不是中文字符，只需要写出这一个 TILE 即可
		LDA #$01
		STA PPU_BUFF_TYPE, X

    LDA POSITION_HI
    STA PPU_BUFF_HI_ADDR, X

    LDA POSITION_LO
    STA PPU_BUFF_LO_ADDR, X

    ; 获取需要打印的字符
    PLA
    STA PPU_BUFF_TILE

    LDA #$FF
    STA PPU_BUFF_END, X

    ; 计算 X 偏移 (8 cycle)
    ; 非中文字符一共写出了 5 个字节
    CLC
    TXA
    ADC #$05

    JMP _END_ADD_CHAR

  _DISPLAY_CHINESE_CHR:
    LDA #$01
    STA CHS_BUFF_TYPE1, X
    STA CHS_BUFF_TYPE2, X

    ; 写出 & 计算定位
    CLC
    LDA POSITION_LO
    STA CHS_BUFF_LO_TOP, X
    ADC #$20  ; #$20 - 刚好换到第二行的相同位置
    STA CHS_BUFF_LO_BOT, X

    LDA POSITION_HI
    STA CHS_BUFF_HI_TOP, X
    ADC #$00  ; #$00 - 如果之前的加法溢出了，此时便会 +1
    STA CHS_BUFF_HI_BOT, X

    ; 写出贴图块
    CLC
    PLA

    ; ID = A * 4
    ASL
    ASL

    STA CHS_BUFF_TILE1, X

    ADC #$01
    STA CHS_BUFF_TILE2, X

    ADC #$01
    STA CHS_BUFF_TILE3, X

    ADC #$01
    STA CHS_BUFF_TILE4, X

    ; 写出结束符
    LDA #$FF
    STA CHS_BUFF_END1, X
    STA CHS_BUFF_END2, X

    INC POSITION_LO

    ; 计算 X 偏移
    TXA
    ADC #$0C

_END_ADD_CHAR:
  ; 跳转前: 请计算写出长度并赋值到寄存器

  ; 修复 PPU 偏移
  STA PPU_BUFF_OFFSET

  ; 下一个写出地址 +1
  INC POSITION_LO
  BCC _NO_INC_POS_HI
    INC POSITION_HI

_NO_INC_POS_HI:
  ; 好像没了

  RTS
; END G_DisplayCharacter -------------------------------------------------------



; BEGIN ContraIntro ------------------------------------------------------------
; 原始内存        04:9034
; 文件地址         011044
; 修改方案            JMP

ContraIntro:
  LDA CI_CURRENT_CHAR
  ; 检查 3x3 字符标记
  AND #$40
  ; 如果没有 (A = 0), 那么就是 2x2
  BEQ _CI_2x2_LETTER
    LDA CI_CURRENT_CHAR
    CLC
    SBC #$40

    ; 跳回去原本的代码
    JMP $90A0

_CI_2x2_LETTER:
  ; Y = (char << 2) & 0x7F
  LDA CI_CURRENT_CHAR
  ASL
  ASL
  AND #$7F
  TAY

  LDA CI_CURRENT_CHAR
  AND #$20
  CLC

  ; 计算坐标 (代码直接拷贝自程序)
  ADC $0042
  STA $0000

  LDA #$00
  ADC $0043
  STA $0001

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

  LDA _DATA_CI_TITLE_TABLE + 0, Y
  STA $0703,X

  LDA _DATA_CI_TITLE_TABLE + 1, Y
  STA $0704,X

  LDA _DATA_CI_TITLE_TABLE + 2, Y
  STA $0709,X

  LDA _DATA_CI_TITLE_TABLE + 3, Y
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

_DATA_CI_TITLE_TABLE:
  ; 00
  .byte $00,$00,$00,$00   ; [空白]
  .byte $02,$03,$12,$13   ; 乃
  .byte $04,$05,$14,$15   ; 斗
  .byte $06,$07,$16,$17   ; 志
  .byte $08,$09,$18,$19   ; 昂
  .byte $00,$00,$00,$00   ; [未使用]
  .byte $0c,$0d,$1c,$1d   ; 扬
  .byte $0e,$0f,$1e,$1f   ; 精
  ; 08
  .byte $20,$21,$30,$31   ; 通
  .byte $22,$23,$32,$33   ; 枪
  .byte $24,$25,$34,$35   ; 械
  .byte $26,$27,$36,$37   ; 并
  .byte $28,$29,$38,$39   ; 拥
  .byte $2a,$2b,$3a,$3b   ; 有
  .byte $0B,$00,$00,$00   ; [前引号]
  .byte $00,$00,$1B,$00   ; [逗号]
  ; 10
  .byte $00,$00,$0A,$00   ; [句号]
  .byte $F7,$F8,$F9,$FA   ; 之
  .byte $FB,$FC,$FD,$FE   ; 名
  .byte $00,$00,$00,$00   ; [未使用]
  .byte $48,$49,$58,$59   ; 与
  .byte $4a,$4b,$5a,$5b   ; 生
  .byte $4c,$4d,$5c,$5d   ; 俱
  .byte $4e,$4f,$5e,$5f   ; 来
  ; 18
  .byte $60,$61,$70,$71   ; 超
  .byte $62,$63,$72,$73   ; 强
  .byte $64,$65,$74,$75   ; 身
  .byte $66,$67,$76,$77   ; 体
  .byte $68,$69,$78,$79   ; 的
  .byte $6a,$6b,$7a,$7b   ; 最
  .byte $6c,$6d,$7c,$7d   ; 战
  .byte $6e,$6f,$7e,$7f   ; 士
  ; 20
; END ContraIntro --------------------------------------------------------------



; --------------------------
; Level Clear Dialog
;       过关剧情文字
; --------------------------

LevelClearDialog:
  DEC LCD_WAIT_COUNTER
  BEQ _LCD_NO_WAIT
_LCD_EXIT_DIALOG_INCOMPLETE:
    CLC
    RTS

_LCD_NO_WAIT:
  LDA #$06    ; A = 06
  STA LCD_WAIT_COUNTER   ; [0047] = 06


  LDA $0030   ; A = [0030]
  ASL       ; A <<= 1
  TAY       ; Y = A

  ; 对话偏移写出到 00, 01 位置
  LDA LCD_DIALOG_LO, Y
  STA ALL_DIALOG_LO
  LDA LCD_DIALOG_HI, Y
  STA ALL_DIALOG_HI

  ; 读取对话偏移
_LCD_GET_NEXT_CHAR:
  LDY LCD_TEXT_OFFSET    ; Y = [0046]
  INC LCD_TEXT_OFFSET

_LCD_CHECK_CHAR:
  LDA (DIALOG_ADDR), Y

  ; 检查控制符: 结束 -----
  CMP #CTRL_END
  BEQ _LCD_END_DIALOG_COMPLETE


  ; 检查控制符: 清屏 -----
  CMP #CTRL_CLEAR
  BNE _LCD_SKIP_CLEAR_SCREEN
    ; 清屏

    ; 首先重置光标位置, 然后清屏
    JSR LCD_ResetPosition
    JSR LCD_ClearLine
    JSR LCD_ResetPosition
    JMP _LCD_EXIT_DIALOG_INCOMPLETE
_LCD_SKIP_CLEAR_SCREEN:

  CMP #CTRL_CLEARLINE
  BNE _LCD_SKIP_CLEARLINE
    JSR LCD_ClearLine
    JMP _LCD_EXIT_DIALOG_INCOMPLETE
_LCD_SKIP_CLEARLINE:


  ; 检查控制符: 换行 -----
  CMP #CTRL_NEWLINE
  BNE _LCD_SKIP_NEWLINE
    INY
    JSR LCD_NewLine
    JMP _LCD_GET_NEXT_CHAR
_LCD_SKIP_NEWLINE:

  ; 检查控制符: 暂停 -----
  CMP #CTRL_PAUSE
  BNE _LCD_SKIP_PAUSE
    LDA #$40
    STA LCD_WAIT_COUNTER
    ; INC LCD_TEXT_OFFSET
    JMP _LCD_EXIT_DIALOG_INCOMPLETE
_LCD_SKIP_PAUSE:

  ; 检查控制符: 中文 -----

  ; 检查是否为中文符号
  ; 如果是, 在传递之前调用一次 [重置位置] 函数。
  ; 因为为了配合通用中文写字程序，需要调整坐标使用的内存地址。
  CMP #CTRL_UPDATE_PPU
  BNE _LCD_SKIP_RESET
    JSR LCD_ResetPosition

    ; 更新 PPU
    JSR G_UpdatePPU

    ; 根据函数说明, 储存当前的对话偏移
    STY LCD_TEXT_OFFSET
    INC LCD_TEXT_OFFSET
    JMP _LCD_CHECK_CHAR

_LCD_SKIP_RESET:

  ; 在屏幕写字~
  CMP #$00
  BEQ _LCG_SKIP_SOUND
    PHA
    LDA #$10
    JSR _fn_PlaySound
    PLA

_LCG_SKIP_SOUND:
  JSR G_DisplayCharacter
  RTS

_LCD_END_DIALOG_COMPLETE:
  SEC
  RTS

; BEGIN LCD_ResetPosition ------------------------------------------------------
LCD_ResetPosition:
  ; 默认写出位置
  LDA #LCD_RESET_HI
  STA LCD_BACKUP_HI
  STA POSITION_HI

  LDA #LCD_RESET_LO
  STA LCD_BACKUP_LO
  STA POSITION_LO

  RTS
; END LCD_ResetPosition --------------------------------------------------------

; BEGIN LCD_NewLine ------------------------------------------------------------
LCD_NewLine:
  CLC
  LDA LCD_BACKUP_LO
  ADC #$40
  STA LCD_BACKUP_LO
  STA POSITION_LO

  LDA LCD_BACKUP_HI
  ADC #$00
  STA LCD_BACKUP_HI
  STA POSITION_HI
  RTS
; END LCD_NewLine --------------------------------------------------------------


; BEGIN LCD_ClearLine --------------------------------------------------------
LCD_ClearLine:
  ; 准备环境

  LDX PPU_BUFF_OFFSET
  LDA #$03

  _LCD_CS_NEXT_LINE:
    PHA

    ; 打标记
    LDA #$01
    STA PPU_BUFF_TYPE, X

    ; 获取当前坐标, 并计算下一次的写出坐标
    CLC
    LDA LCD_BACKUP_LO
    STA PPU_BUFF_LO_ADDR, X
    ADC #$20
    STA POSITION_LO
    STA LCD_BACKUP_LO

    LDA LCD_BACKUP_HI
    STA PPU_BUFF_HI_ADDR, X
    ADC #$00
    STA LCD_BACKUP_HI
    STA POSITION_HI


    ; 写出 16 个空白字符
    LDY #$D
    LDA #$00
_LCD_CS_LOOP_CHAR:
      STA PPU_BUFF_TILE, X
      INX
      DEY
      BNE _LCD_CS_LOOP_CHAR

    ; 打上结束标记
    LDA #$FF
    STA PPU_BUFF_TILE, X

    INX
    INX
    INX
    INX

    ; 清理一行的控制符打上了
    ; 检查循环
    PLA
    SEC
    SBC #$01
    BNE _LCD_CS_NEXT_LINE

  ; X 被修改了，记录长度
  STX PPU_BUFF_OFFSET

  RTS
; END LCD_ClearLine ----------------------------------------------------------



; BEGIN PrologueDialog ---------------------------------------------------------
PrologueDialog:
  DEC PLD_WAIT_COUNTER
  BNE _PLD_END

  ; 设定下个字符的等待时间
  LDA #$08
  STA PLD_WAIT_COUNTER

  ; 取得当前对话的序号并计算偏移
  ; Y = [PLD_CUR_DIALOG] << 1
  LDA PLD_CUR_DIALOG
  ASL
  TAY

  ; 取得当前对话指针
  LDA PLD_DIALOGS_LO,Y
  STA ALL_DIALOG_LO
  LDA PLD_DIALOGS_HI, Y
  STA ALL_DIALOG_HI

  ; 取得在当前对话的偏移
_PLD_NEXT_CHAR:
  LDY PLD_TEXT_OFFSET
  INC PLD_TEXT_OFFSET

_PLD_CHECK_CHAR:
  LDA (DIALOG_ADDR), Y
  CMP #CTRL_END
  BEQ _PLD_DIALOG_FINISH

  CMP #CTRL_NEWLINE
  BNE _PLD_NOT_NEWLINE
    ; 换行符号
    INC PLD_LINE_COUNT
    JSR PLD_NewLine
    JMP _PLD_NEXT_CHAR

_PLD_NOT_NEWLINE:
  CMP #CTRL_UPDATE_PPU
  BNE _PLD_SKIP_PPU
    ; 中文符号
    ; 1. 检查并切换 PPU
    ; 2. 显示下一个字符

    ; 更新 PPU
    JSR G_UpdatePPU

    ; 根据函数说明, 储存当前的对话偏移
    STY PLD_TEXT_OFFSET
    INC PLD_TEXT_OFFSET

    JMP _PLD_CHECK_CHAR
_PLD_SKIP_PPU:

  ; 检查是否为空格
  ; 如果是空格就不发出打字音
  CMP #$00
  BEQ _PLD_SKIP_SOUND
    PHA
    LDA #$10
    JSR _fn_PlaySound
    PLA

_PLD_SKIP_SOUND:
  ; 结束控制符检查
  ; 显示字符到屏幕
  JSR G_DisplayCharacter
  RTS


_PLD_END:
  CLC
  RTS

_PLD_DIALOG_FINISH:
  SEC
  RTS


; END PrologueDialog -----------------------------------------------------------



; BEGIN PLD_NewLine ------------------------------------------------------------
; 输入: 无
; 影响:
;   * Y: 换行次数
;   * A: PPU 地址高位
PLD_NewLine:
  ; 读取下一行的位置的偏移地址
  LDA PLD_CUR_DIALOG
  ASL
  TAY

  LDA PLD_DIALOG_POS_LO,Y
  STA PLD_TMP_POS_LO
  LDA PLD_DIALOG_POS_HI,Y
  STA PLD_TMP_POS_HI

  ; 写出 PPU 定位地址
  ; Y = [PLD_LINE_COUNT] << 1
  LDA PLD_LINE_COUNT
  ASL
  TAY

  LDA (PLD_TMP_POS_LO),Y
  STA POSITION_LO
  INY
  LDA (PLD_TMP_POS_LO),Y
  STA POSITION_HI
  RTS
; END PLD_NewLine --------------------------------------------------------------



; BEGIN ScrectEnding -----------------------------------------------------------
ScrectEnding:
  LDA #PPU_RENDER_TILE
  STA G_PPU_RENDER_TYPE

  LDA SED_DIALOG_LO, Y
  STA ALL_DIALOG_LO
  LDA SED_DIALOG_HI, Y
  STA ALL_DIALOG_HI

_SED_GET_NEXT_CHAR:
	LDY SED_TEXT_OFFSET
	INC SED_TEXT_OFFSET

_SED_CHECK_CHAR:
  LDA (DIALOG_ADDR), Y

  ; 如果是空格
  CMP #CTRL_PAUSE
  BNE _SED_NOT_PAUSE
    ; 这部分的程序等待是向上计时的，重置为 01 刚好。
    ; 如果 A = 00 就认为是结束了
    LDA #$01
    STA SED_WAIT_COUNTER
    RTS
_SED_NOT_PAUSE:

  CMP #CTRL_END
  BEQ _SED_EXIT_COMPLETE

  CMP #CTRL_NEWLINE
  BNE _SED_NOT_NEWLINE
    ; 换行操作
    JSR SED_NewLine
    JMP _SED_GET_NEXT_CHAR

_SED_NOT_NEWLINE:
  CMP #CTRL_UPDATE_PPU
  BNE _SED_NOT_UPDATE_PPU
    ; 重置坐标
    JSR SED_ResetPosition

    JSR G_UpdatePPU
    ; 根据函数说明进行清理工作
    STY SED_TEXT_OFFSET
    INC SED_TEXT_OFFSET
    JMP _SED_CHECK_CHAR

_SED_NOT_UPDATE_PPU:

  CMP #$00
  BEQ _SED_SKIP_SOUND
    PHA
    LDA #$10
    JSR _fn_PlaySound
    PLA

_SED_SKIP_SOUND:

  ; 开始显示字符
  JSR G_DisplayCharacter


_SED_EXIT:
  RTS

_SED_EXIT_COMPLETE:
  LDA #$00
  RTS

; END ScrectEnding -------------------------------------------------------------



; BEGIN SED_NewLine -----
SED_NewLine:
  CLC
  LDA SED_POS_LO
  ADC #$40
  STA SED_POS_LO
  STA POSITION_LO

  LDA SED_POS_HI
  ADC #$00
  STA SED_POS_HI
  STA POSITION_HI

  RTS
; END SED_NewLine -------

; BEGIN SED_ResetPosition -----
SED_ResetPosition:
  ; 将地址重置为 20 C3
  LDA #$20
  STA POSITION_HI
  STA SED_POS_HI

  LDA #$C3
  STA POSITION_LO
  STA SED_POS_LO
  RTS

; END SED_ResetPosition -------
