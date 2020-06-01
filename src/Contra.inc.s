; 魂斗罗部分地址偏移 / 常量

; Function Import --------------------------
.alias _fn_PrologueDialog     $AB70
.alias _fn_ContraIntro        $AB73
.alias _fn_LevelClearDialog   $AB76
.alias _fn_ScrectEnding       $AB79

; 原本就在魂斗罗 Rom 内的函数地址
.alias _fn_PlaySound          $F9BC
; END Function Import ----------------------



; 定位地址
.alias POSITION_LO        $0049
.alias POSITION_HI        $004A



; 写出基地址
.alias PPU_BUFF_OFFSET    $0021

.alias PPU_BUFF_TYPE      $0700
.alias PPU_BUFF_HI_ADDR   $0701
.alias PPU_BUFF_LO_ADDR   $0702
.alias PPU_BUFF_TILE      $0703
.alias PPU_BUFF_END       $0704

; Used by ScrectEnding
; Set to 00 to render until FF.
.alias G_PPU_RENDER_TYPE  $0023
.alias PPU_RENDER_TILE    $00


; 中文字符缓冲区开始 -------------------------
.alias CHS_BUFF_TYPE1     $0700
.alias CHS_BUFF_HI_TOP    $0701
.alias CHS_BUFF_LO_TOP    $0702
.alias CHS_BUFF_TILE1     $0703
.alias CHS_BUFF_TILE2     $0704
.alias CHS_BUFF_END1      $0705

.alias CHS_BUFF_TYPE2     $0706
.alias CHS_BUFF_HI_BOT    $0707
.alias CHS_BUFF_LO_BOT    $0708
.alias CHS_BUFF_TILE3     $0709
.alias CHS_BUFF_TILE4     $070A
.alias CHS_BUFF_END2      $070B
; 中文字符缓冲区结束 -------------------------



; 中文控制符开始 -----------------------------
.alias CTRL_END           $FF
.alias CTRL_NEWLINE       $FE
.alias CTRL_UPDATE_PPU    $FD
.alias CTRL_CLEAR         $FC
.alias CTRL_WAIT          $FB
.alias CTRL_PAUSE         $FB
.alias CTRL_CLEARLINE     $FA


.alias CHS_CHAR_FLAG      $80
.alias CHS_CHAR_MASK      $C0

.alias CHS_CTRL_FLAG      $C0
.alias CHS_CTRL_MASK      $C0
; 中文控制符结束 -----------------------------



; BEGIN PPU Bank ---------------------------
.alias CHR_BANK_BASE      $07F0

.alias CHR_BANK_0         $07F0
.alias CHR_BANK_1         $07F1
.alias CHR_BANK_2         $07F2
.alias CHR_BANK_3         $07F3
.alias CHR_BANK_4         $07F4
.alias CHR_BANK_5         $07F5
.alias CHR_BANK_6         $07F6
.alias CHR_BANK_7         $07F7
; END PPU Bank -----------------------------



; BEGIN Dialog Generic ---------------------
.alias ALL_DIALOG_HI      $0001
.alias ALL_DIALOG_LO      $0000

.alias DIALOG_ADDR        $0000
; END Dialog Generic -----------------------



; BEGIN Contra Intro -----------------------
.alias CI_CURRENT_CHAR    $0008
; END Contra Intro -------------------------



; BEGIN Level Clear Dialog -----------------
.alias LCD_RESET_HI       $21
.alias LCD_RESET_LO       $11

.alias LCD_TEXT_OFFSET    $0046
.alias LCD_WAIT_COUNTER   $0047

; 行首位置
.alias LCD_BACKUP_LO      $0048
.alias LCD_BACKUP_HI      $004B

; 对话文字偏移
.alias LCD_DIALOG_HI      $A1D7
.alias LCD_DIALOG_LO      $A1D6
; END Level Clear Dialog -------------------




; BEGIN Prologue Dialog --------------------
.alias PLD_WAIT_COUNTER   $0043
.alias PLD_CUR_DIALOG     $0046
.alias PLD_TEXT_OFFSET    $0047
.alias PLD_LINE_COUNT     $0048

.alias PLD_DIALOGS_HI     $9849
.alias PLD_DIALOGS_LO     $9848

.alias PLD_DIALOG_POS_HI  $97DC
.alias PLD_DIALOG_POS_LO  $97DB

.alias PLD_TMP_POS_ADDR   $0002
.alias PLD_TMP_POS_HI     $0003
.alias PLD_TMP_POS_LO     $0002
; END Prologue Dialog ----------------------


; BEGIN ScrectEnding -----------------------
.alias SED_WAIT_COUNTER   $001A
.alias SED_TEXT_OFFSET    $0042

.alias SED_DIALOG_LO      $855B
.alias SED_DIALOG_HI      $855C

.alias SED_POS_LO         $0043
.alias SED_POS_HI         $0044

; END ScrectEnding -------------------------
