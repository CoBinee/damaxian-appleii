; title.s - タイトル
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
.include    "field.inc"
.include    "title.inc"
.include    "star.inc"


; コードの定義
;
.segment    "APP"

; タイトルのエントリポイント
;
.global _TitleEntry
.proc   _TitleEntry

    ; アプリケーションの初期化

    ; タイトルの初期化
    jsr     TitleInitialize

    ; 星の初期化
    jsr     _StarInitialize
    jsr     _StarPatch

    ; 処理の設定
    lda     #<TitleIdle
    sta     APP_0_PROC_L
    lda     #>TitleIdle
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
    rts

.endproc

; タイトルを初期化する
;
.proc   TitleInitialize

    ; WORK
    ;   TITLE_0_WORK_0..1

    ; 0 クリア
    ldx     #$00
    lda     #$00
:
    sta     title, x
    inx
    cpx     #(.sizeof(Title))
    bne     :-

    ; フィールドのクリア
    jsr     _FieldClear

    ; タイルセットの調整
    lda     #<logo_tileset
    sta     TITLE_0_WORK_0
    lda     #>logo_tileset
    sta     TITLE_0_WORK_1
    ldy     #$00
:
    lda     (TITLE_0_WORK_0), y
    ora     #$80
    sta     (TITLE_0_WORK_0), y
    inc     TITLE_0_WORK_0
    bne     :+
    inc     TITLE_0_WORK_1
:
    lda     TITLE_0_WORK_0
    cmp     #<(logo_tileset + $001a * $0003 * $0008)
    bne     :--
    lda     TITLE_0_WORK_1
    cmp     #>(logo_tileset + $001a * $0003 * $0008)
    bne     :--

    ; ロゴの描画
    ldx     #<@draw_logo_arg
    lda     #>@draw_logo_arg
    jsr     _IocsDraw7x8Tilemap

    ; 終了
    rts

; ロゴ
@draw_logo_arg:
    .byte   $03, $08
    .byte   $1a, $03
    .word   logo_tileset
    .word   logo_tilemap
    .byte   $00, $00

.endproc

; タイトルを待機する
;
.proc   TitleIdle

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; タイトルの更新
    jsr     TitleUpdate

    ; 点滅の更新
    inc     title + Title::blink

    ; キー入力の監視
    lda     IOCS_0_KEYCODE
    beq     @end

    ; 処理の設定
    lda     #<TitleStart
    sta     APP_0_PROC_L
    lda     #>TitleStart
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
@end:
    rts

.endproc

; タイトルからゲームを開始する
;
.proc   TitleStart

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; カウントの設定
    lda     #$00
    sta     title + Title::count

    ; BEEP
;   lda     #$87
;   jsr     BELL1
    ldx     #<@beep
    lda     #>@beep
    jsr     _IocsBeepQue

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; タイトルの更新
    jsr     TitleUpdate

    ; 点滅の更新
    lda     title + Title::blink
    clc
    adc     #$08
    sta     title + Title::blink

    ; カウントの更新
    dec     title + Title::count
    bne     @end

    ; 処理の設定
    lda     #<TitleEnd
    sta     APP_0_PROC_L
    lda     #>TitleEnd
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
@end:
    rts

; BEEP
@beep:
    .byte   IOCS_BEEP_PI, 12
    .byte   IOCS_BEEP_PO, 12
    .byte   IOCS_BEEP_END

.endproc

; タイトルを終了する
;
.proc   TitleEnd

    ; 処理の設定
    lda     #<_GameEntry
    sta     APP_0_PROC_L
    lda     #>_GameEntry
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
    rts

.endproc

; タイトルを更新する
;
.proc   TitleUpdate

    ; 星の更新
    jsr     _StarUpdate

    ; 明滅の更新
    inc     title + Title::flick_count
    lda     title + Title::flick_count
    and     #$0f
    bne     :+
    lda     title + Title::flick_draw
    sta     title + Title::flick_erase
    jsr     _IocsGetRandomNumber
    and     #$07
    sta     title + Title::flick_draw
:

    ; 星の描画
    jsr     _StarRender

    ; ロゴの明滅
    lda     title + Title::flick_count
    and     #$07
    bne     @draw_logo_end

    ; 直前の明滅の復帰
    ldx     title + Title::flick_erase
    lda     @flick_logo_x, x
    sta     @erase_logo_arg + $0008
    clc
    adc     #$03
    sta     @erase_logo_arg + $0000
    lda     @flick_logo_width, x
    sta     @erase_logo_arg + $0002
    ldx     #<@erase_logo_arg
    lda     #>@erase_logo_arg
    jsr     _IocsDraw7x8Tilemap

    ; 明滅の描画
    lda     title + Title::flick_draw
    sta     TITLE_0_FLICK_INDEX
    tax
    lda     @flick_logo_x, x
    clc
    adc     #$03
    sta     TITLE_0_FLICK_X
    lda     #$08
    sta     TITLE_0_FLICK_Y
    lda     @flick_logo_width, x
    sta     TITLE_0_FLICK_WIDTH
    lda     #$03
    sta     TITLE_0_FLICK_HEIGHT
:
    ldx     TITLE_0_FLICK_Y
    lda     _iocs_hgr_tile_y_address_low, x
    clc
    adc     TITLE_0_FLICK_X
    sta     TITLE_0_FLICK_VRAM_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     TITLE_0_FLICK_VRAM_H
    ldx     #$08
:
    ldy     #$00
:
    lda     (TITLE_0_FLICK_VRAM), y
;   ora     #$80
    and     #$7f
    sta     (TITLE_0_FLICK_VRAM), y
    iny
    cpy     TITLE_0_FLICK_WIDTH
    bne     :-
    lda     TITLE_0_FLICK_VRAM_H
    clc
    adc     #$04
    sta     TITLE_0_FLICK_VRAM_H
    dex
    bne     :--
    inc     TITLE_0_FLICK_Y
    dec     TITLE_0_FLICK_HEIGHT
    bne     :---
@draw_logo_end:

    ; キー入力待ちの描画
    lda     title + Title::blink
    and     #%10000000
    bne     :+
    ldx     #<@draw_inkey_arg
    lda     #>@draw_inkey_arg
    jmp     :++
:
    ldx     #<@erase_inkey_arg
    lda     #>@erase_inkey_arg
:
    jsr     _IocsDrawString

    ; 終了
    rts

; ロゴ
@erase_logo_arg:
    .byte   $00, $08
    .byte   $00, $03
    .word   logo_tileset
    .word   logo_tilemap
    .byte   $00, $00
@flick_logo_x:
    .byte   $00, $04, $07, $0a, $0e, $11, $13, $16
@flick_logo_width:
    .byte   $04, $03, $03, $04, $03, $02, $03, $04

; キー入力待ち
@draw_inkey_arg:
    .byte   $0b, $10
    .word   @draw_inkey_string
@draw_inkey_string:
    .byte   _NA, _NI, _KA, ' ', _KI, _HF, _WO, ' ', __O, _SU, $00
@erase_inkey_arg:
    .byte   $0b, $10
    .word   @erase_inkey_string
@erase_inkey_string:
    .asciiz "          "

.endproc

; タイルセット
;
logo_tileset:
    .incbin "resources/tiles/logo.ts"

; タイルマップ
;
logo_tilemap:
    .byte   $1a, $03
    .byte   $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
    .byte   $1a, $1b, $1c, $1d, $1e, $1f, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f, $30, $31, $32, $33
    .byte   $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d


; データの定義
;
.segment    "BSS"

; タイトル
;
title:
    .tag    Title

