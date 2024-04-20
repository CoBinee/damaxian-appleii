; shot.s - ショット
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
.include    "game.inc"
.include    "shot.inc"


; コードの定義
;
.segment    "APP"

; ショットを初期化する
;
.global _ShotInitialize
.proc   _ShotInitialize

    ; ショットの初期化
    ldx     #$00
@init:

    ; 状態の設定
    lda     #$00
    sta     _shot_state, x

    ; 次のショットへ
    inx
    cpx     #SHOT_ENTRY
    bne     @init

    ; 終了
    rts

.endproc

; ショットを更新する
;
.global _ShotUpdate
.proc   _ShotUpdate

    ; ショットの走査
    ldx     #$00
@update:

    ; ショットの存在
    lda     _shot_state, x
    beq     @next

    ; 位置の保存
    lda     _shot_position_y, x
    bmi     @next
    sta     shot_last_y, x
    lda     shot_position_y_tile, x
    sta     shot_last_y_tile, x

    ; Y 位置の更新
    lda     _shot_position_y, x
    sec
    sbc     #$04
    sta     _shot_position_y, x
    dec     shot_position_y_tile, x
    jmp     @next

    ; 次のショットへ
@next:
    inx
    cpx     #SHOT_ENTRY
    bne     @update

    ; 終了
    rts

.endproc

; ショットの後始末をする
;
.global _ShotCleanup
.proc   _ShotCleanup

    ; ショットの走査
    ldx     #$00
@cleanup:

    ; ショットの存在
    lda     _shot_state, x
    beq     @next

    ; 画面外のショットは削除
    lda     _shot_position_y, x
    bpl     @next
    lda     #$00
    sta     _shot_state, x

    ; 次のショットへ
@next:
    inx
    cpx     #SHOT_ENTRY
    bne     @cleanup

    ; 終了
    rts

.endproc

; ショットを描画する
;
.global _ShotRender
.proc   _ShotRender

    ; WORK
    ;   GAME_0_WORK_0..2

    ; ショットの走査
    ldx     #$00
@render:

    ; 状態の設定
    lda     _shot_state, x
    beq     @next

    ; 消去の判定
    lda     shot_last_y_tile, x
    bmi     @erase_end
    cmp     shot_position_y_tile, x
    beq     @erase_end

    ; 消去する VRAM アドレスの取得
    tay
    bmi     @erase_end
    lda     _iocs_hgr_tile_y_address_high, y
    sta     GAME_0_WORK_1
    lda     _iocs_hgr_tile_y_address_low, y
    clc
    adc     shot_position_x_tile, x
    sta     GAME_0_WORK_0
    bcc     :+
    inc     GAME_0_WORK_1
:

    ; ショットの消去
    lda     #$08
    sta     GAME_0_WORK_2
:
    ldy     #$00
    lda     shot_tileset_erase_0, x
    and     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
    lda     shot_tileset_erase_1, x
    cmp     #$ff
    beq     :+
    iny
    and     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
:
    lda     GAME_0_WORK_1
    clc
    adc     #$04
    sta     GAME_0_WORK_1
    dec     GAME_0_WORK_2
    bne     :--
@erase_end:

    ; 描画の判定
    lda     shot_position_y_tile, x
    bmi     @draw_end

    ; 描画する VRAM アドレスの取得
    tay
    lda     _iocs_hgr_tile_y_address_high, y
    sta     GAME_0_WORK_1
    lda     _iocs_hgr_tile_y_address_low, y
    clc
    adc     shot_position_x_tile, x
    sta     GAME_0_WORK_0
    bcc     :+
    inc     GAME_0_WORK_1
:

    ; ショットの描画
    lda     #$08
    sta     GAME_0_WORK_2
:
    ldy     #$00
    lda     shot_tileset_draw_0, x
    ora     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
    lda     shot_tileset_draw_1, x
    beq     :+
    iny
    ora     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
:
    lda     GAME_0_WORK_1
    clc
    adc     #$04
    sta     GAME_0_WORK_1
    dec     GAME_0_WORK_2
    bne     :--
@draw_end:

    ; 次のショットへ
@next:
    inx
    cpx     #SHOT_ENTRY
    beq     :+
    jmp     @render
:

    ; 終了
    rts

.endproc

; ショットを撃つ
;
.global _ShotShoot
.proc   _ShotShoot

    ; IN
    ;   a = X 位置

    ; X 位置の保存
    tay

    ; ショットの取得
    ldx     #$00
:
    lda     _shot_state, x
    beq     @entry
    inx
    cpx     #SHOT_ENTRY
    bne     :-
    rts

    ; ショットの登録
@entry:

    ; 状態の設定
    inc     _shot_state, x

    ; X 位置の設定
    tya
    sta     _shot_position_x, x
    lda     @x_tile, y
    sta     shot_position_x_tile, x

    ; Y 位置の取得
    lda     #SHOT_Y_START
    sta     _shot_position_y, x
    sta     shot_last_y, x
    lda     #SHOT_Y_START / 4
    sta     shot_position_y_tile, x
    sta     shot_last_y_tile, x

    ; タイルセットの設定
    lda     @tileset_0, y
    sta     shot_tileset_draw_0, x
    eor     #$ff
    sta     shot_tileset_erase_0, x
    lda     @tileset_1, y
    sta     shot_tileset_draw_1, x
    eor     #$ff
    sta     shot_tileset_erase_1, x

    ; 終了
    rts

; X タイル位置
@x_tile:
    .byte   $00, $00, $00, $00, $01, $01, $01
    .byte   $02, $02, $02, $02, $03, $03, $03
    .byte   $04, $04, $04, $04, $05, $05, $05
    .byte   $06, $06, $06, $06, $07, $07, $07
    .byte   $08, $08, $08, $08, $09, $09, $09
    .byte   $0a, $0a, $0a, $0a, $0b, $0b, $0b
    .byte   $0c, $0c, $0c, $0c, $0d, $0d, $0d
    .byte   $0e, $0e, $0e, $0e, $0f, $0f, $0f
    .byte   $10, $10, $10, $10, $11, $11, $11
    .byte   $12, $12, $12, $12, $13, $13, $13
    .byte   $14, $14, $14, $14, $15, $15, $15
    .byte   $16, $16, $16, $16, $17, $17, $17
    .byte   $18, $18, $18, $18, $19, $19, $19
    .byte   $1a, $1a, $1a, $1a, $1b, $1b, $1b
    .byte   $1c, $1c, $1c, $1c, $1d, $1d, $1d
    .byte   $1e, $1e, $1e, $1e, $1f, $1f, $1f

; タイルセット
@tileset_0:
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
    .byte   $03, $0c, $30, $40, $06, $18, $60
@tileset_1:
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00
    .byte   $00, $00, $00, $01, $00, $00, $00

.endproc

; ショットを削除する;
;
.global _ShotKill
.proc   _ShotKill

    ; IN
    ;   x = ショットの参照

    ; ショットを外に出す
    lda     _shot_position_y, x
    sta     shot_last_y, x
    lda     shot_position_y_tile, x
    sta     shot_last_y_tile, x
    lda     #$f8
    sta     _shot_position_y, x
    lda     #$ff
    sta     shot_position_y_tile, x

    ; 終了
    rts

.endproc


; データの定義
;
.segment    "BSS"

; ショット
;

; 状態
.global _shot_state
_shot_state:
    .res    SHOT_ENTRY

; 位置
.global _shot_position_x
_shot_position_x:
    .res    SHOT_ENTRY
shot_position_x_tile:
    .res    SHOT_ENTRY
.global _shot_position_y
_shot_position_y:
    .res    SHOT_ENTRY
shot_position_y_tile:
    .res    SHOT_ENTRY

; 直前の位置
shot_last_y:
    .res    SHOT_ENTRY
shot_last_y_tile:
    .res    SHOT_ENTRY

; タイルセット
shot_tileset_draw_0:
    .res    SHOT_ENTRY
shot_tileset_draw_1:
    .res    SHOT_ENTRY
shot_tileset_erase_0:
    .res    SHOT_ENTRY
shot_tileset_erase_1:
    .res    SHOT_ENTRY
