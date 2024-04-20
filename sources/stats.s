; stats.s - スタッツ
;


; 6502 - CPU の選択
.setcpu     "6502"

; 自動インポート
.autoimport +

; エスケープシーケンスのサポート
.feature    string_escapes


; ファイルの参照
;
.include    "apple2.inc"
.include    "iocs.inc"
.include    "lib.inc"
.include    "app.inc"
.include    "stats.inc"


; コードの定義
;
.segment    "APP"

; スタッツを初期化する
;
.global _StatsInitialize
.proc   _StatsInitialize

    ; 0 クリア
    ldx     #$00
    lda     #$00
:
    sta     _stats, x
    inx
    cpx     #(.sizeof(Stats))
    bne     :-

    ; スコアの設定

    ; ハイスコアの設定
    lda     #$05
    sta     _stats + Stats::hiscore_00001000

    ; レートの設定
    lda     #$01
    sta     _stats + Stats::rate_0010

    ; タイムの設定

    ; スコアの描画
    ldx     #<@score_string_arg
    lda     #>@score_string_arg
    jsr     _IocsDrawString
    
    ; ハイスコアの描画
    ldx     #<@hiscore_string_arg
    lda     #>@hiscore_string_arg
    jsr     _IocsDrawString
    
    ; レートの描画
    ldx     #<@rate_string_arg
    lda     #>@rate_string_arg
    jsr     _IocsDrawString
    
    ; タイムの描画
    ldx     #<@time_string_arg
    lda     #>@time_string_arg
    jsr     _IocsDrawString

    ; スタッツの描画
    lda     #$01
    sta     _stats + Stats::score_draw
    sta     _stats + Stats::hiscore_draw
    sta     _stats + Stats::rate_draw
    sta     _stats + Stats::time_draw
    jsr     _StatsRender
    
    ; 終了
    rts

; スコア
@score_string_arg:
    .byte   32, 1
    .word   @score_string
@score_string:
    .byte   _TO, _KU, _TE, __N, $00

; ハイスコア
@hiscore_string_arg:
    .byte   32, 4
    .word   @hiscore_string
@hiscore_string:
    .byte   _SA, __I, _KO, __U, _TO, _KU, _TE, __N, $00

; レート
@rate_string_arg:
    .byte   32, 18
    .word   @rate_string
@rate_string:
    .byte   _BA, __I, _RI, _TU, $00

; タイム
@time_string_arg:
    .byte   32, 21
    .word   @time_string
@time_string:
    .byte   _ZI, _KA, __N, $00

.endproc

; スタッツを開始する
;
.global _StatsLoad
.proc   _StatsLoad

    ; スコアのクリア
    lda     #$00
    sta     _stats + Stats::score_10000000
    sta     _stats + Stats::score_01000000
    sta     _stats + Stats::score_00100000
    sta     _stats + Stats::score_00010000
    sta     _stats + Stats::score_00001000
    sta     _stats + Stats::score_00000100
    sta     _stats + Stats::score_00000010
    sta     _stats + Stats::score_00000001
    lda     #$01
    sta     _stats + Stats::score_draw

    ; レートのクリア
    lda     #$00
    sta     _stats + Stats::rate_1000
    sta     _stats + Stats::rate_0100
    sta     _stats + Stats::rate_0001
    lda     #$01
    sta     _stats + Stats::rate_0010
    sta     _stats + Stats::rate_draw

    ; タイムの設定
    lda     #$00
    sta     _stats + Stats::time_0100
    sta     _stats + Stats::time_0010
    sta     _stats + Stats::time_0001
    lda     #$01
    sta     _stats + Stats::time_1000
    sta     _stats + Stats::time_draw

    ; 終了
    rts

.endproc

; スタッツを描画する
;
.global _StatsRender
.proc   _StatsRender

    ; WORK
    ;  APP_0_WORK_0..2

    ; スコアの描画
    lda     _stats + Stats::score_draw
    beq     @score_end
    lda     #32
    sta     @draw_number_arg + $0000
    lda     #2
    sta     @draw_number_arg + $0001
    lda     #<(_stats + Stats::score_10000000)
    sta     APP_0_WORK_0
    lda     #>(_stats + Stats::score_10000000)
    sta     APP_0_WORK_1
    lda     #($08 - $01)
    sta     APP_0_WORK_2
    jsr     @draw_number
    lda     #$00
    sta     _stats + Stats::score_draw
@score_end:

    ; ハイスコアの描画
    lda     _stats + Stats::hiscore_draw
    beq     @hiscore_end
    lda     #32
    sta     @draw_number_arg + $0000
    lda     #5
    sta     @draw_number_arg + $0001
    lda     #<(_stats + Stats::hiscore_10000000)
    sta     APP_0_WORK_0
    lda     #>(_stats + Stats::hiscore_10000000)
    sta     APP_0_WORK_1
    lda     #($08 - $01)
    sta     APP_0_WORK_2
    jsr     @draw_number
    lda     #$00
    sta     _stats + Stats::hiscore_draw
@hiscore_end:

    ; レートの描画
    lda     _stats + Stats::rate_draw
    beq     @rate_end
    lda     #35
    sta     @draw_number_arg + $0000
    lda     #19
    sta     @draw_number_arg + $0001
    ldx     #$00
:
    lda     _stats + Stats::rate_1000, x
    bne     :+
    lda     #' '
    sta     @draw_number_string, x
    inx
    cpx     #($03 - $01)
    bne     :-
:
    lda     _stats + Stats::rate_1000, x
    clc
    adc     #'0'
    sta     @draw_number_string, x
    inx
    cpx     #$03
    bne     :-
    lda     #'.'
    sta     @draw_number_string, x
    inx
    lda     _stats + Stats::rate_0001
    clc
    adc     #'0'
    sta     @draw_number_string, x
    inx
    lda     #$00
    sta     @draw_number_string, x
    ldx     #<@draw_number_arg
    lda     #>@draw_number_arg
    jsr     _IocsDrawString
    lda     #$00
    sta     _stats + Stats::rate_draw
@rate_end:

    ; タイムの描画
    lda     _stats + Stats::time_draw
    beq     @time_end
    lda     #36
    sta     @draw_number_arg + $0000
    lda     #22
    sta     @draw_number_arg + $0001
    lda     #<(_stats + Stats::time_1000)
    sta     APP_0_WORK_0
    lda     #>(_stats + Stats::time_1000)
    sta     APP_0_WORK_1
    lda     #($04 - $01)
    sta     APP_0_WORK_2
    jsr     @draw_number
    lda     #$00
    sta     _stats + Stats::time_draw
@time_end:

    ; 終了
    rts

; 数値の描画
@draw_number:
    ldy     #$00
:
    lda     (APP_0_WORK_0), y
    bne     :+
    lda     #' '
    sta     @draw_number_string, y
    iny
    cpy     APP_0_WORK_2
    bne     :-
:
    inc     APP_0_WORK_2
:
    lda     (APP_0_WORK_0), y
    clc
    adc     #'0'
    sta     @draw_number_string, y
    iny
    cpy     APP_0_WORK_2
    bne     :-
    lda     #$00
    sta     @draw_number_string, y
    ldx     #<@draw_number_arg
    lda     #>@draw_number_arg
    jsr     _IocsDrawString
    rts
@draw_number_arg:
    .byte   $00, $00
    .word   @draw_number_string
@draw_number_string:
    .asciiz "01234567"

.endproc


; データの定義
;
.segment    "BSS"

; スタッツ
;
.global _stats
_stats:
    .tag    Stats

