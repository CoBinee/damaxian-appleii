; star.s - 星
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
.include    "star.inc"


; コードの定義
;
.segment    "APP"

; 星を初期化する
;
.global _StarInitialize
.proc   _StarInitialize

    ; WORK
    ;   GAME_0_WORK_0

    ; Y 位置の作成
    ldx     #$00
:
    txa
    sta     @position_y, x
    inx
    cpx     #$18
    bne     :-
    ldy     #$01
:
    tya
    sta     @position_y, x
    iny
    iny
    iny
    inx
    cpx     #STAR_ENTRY
    bne     :-
    ldx     #$00
:
    jsr     _IocsGetRandomNumber
    and     #$1f
    tay
    lda     @position_y, x
    sta     GAME_0_WORK_0
    lda     @position_y, y
    sta     @position_y, x
    lda     GAME_0_WORK_0
    sta     @position_y, y
    inx
    cpx     #STAR_ENTRY
    bne     :-

    ; 星の初期化
    ldx     #$00
@init:

    ; 位置の設定
    lda     @position_y, x
    sta     star_position_y, x

    ; VRAM アドレスの設定
    tay
    txa
    clc
    adc     _iocs_hgr_tile_y_address_low, y
    sta     star_vram_low, x
    lda     _iocs_hgr_tile_y_address_high, y
    clc
    adc     #$0c
    sta     star_vram_high, x

    ; アニメーションの設定
    jsr     _IocsGetRandomNumber
    sta     star_animation, x

    ; 色の設定
    jsr     _IocsGetRandomNumber
    and     #%10011000
    sta     star_color, x

    ; 描画の設定
    lda     #%00100000
    sta     star_draw, x
    lda     #%00111111
    sta     star_erase, x

    ; 次の星へ
    inx
    cpx     #STAR_ENTRY
    bne     @init

    ; 終了
    rts

; Y 位置
@position_y:
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00

.endproc

; 星を更新する
;
.global _StarUpdate
.proc   _StarUpdate

    ; 星の走査
    ldx     #$00
@update:

    ; アニメーションの更新
    inc     star_animation, x

    ; 次の星へ
    inx
    cpx     #STAR_ENTRY
    bne     @update

    ; 終了
    rts

.endproc

; 星を描画する
;
.global _StarRender
.proc   _StarRender

    ; WORK
    ;   GAME_0_WORK_0..1

    ; 星の走査
    ldx     #$00
    ldy     #$00
@render:

    ; 位置の確認
    lda     star_position_y, x
    bmi     @next

    ; VRAM アドレスの取得
    lda     star_vram_low, x
    sta     GAME_0_WORK_0
    lda     star_vram_high, x
    sta     GAME_0_WORK_1

    ; 消去
@erase:
    lda     star_animation, x
    and     star_erase, x
    bne     @draw
    lda     #%01100111
    and     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
    lda     GAME_0_WORK_1
    clc
    adc     #$04
    sta     GAME_0_WORK_1
    lda     #%01100111
    and     (GAME_0_WORK_0), y
    sta     (GAME_0_WORK_0), y
    jmp     @next

    ; 描画
@draw:
;   lda     star_animation, x
    and     star_draw, x
    beq     @next
    lda     #%01100111
    and     (GAME_0_WORK_0), y
    ora     star_color, x
    sta     (GAME_0_WORK_0), y
    lda     GAME_0_WORK_1
    clc
    adc     #$04
    sta     GAME_0_WORK_1
    lda     #%01100111
    and     (GAME_0_WORK_0), y
    ora     star_color, x
    sta     (GAME_0_WORK_0), y
;   jmp     @next

    ; 次の星へ
@next:
    inx
    cpx     #STAR_ENTRY
    bne     @render

    ; 終了
    rts

.endproc

; タイトル用のパッチを当てる
;
.global _StarPatch
.proc   _StarPatch

    ; 星の走査
    ldx     #$00
:

    ; Y 位置が 8..10 の星は処理しない
    lda     star_position_y, x
    cmp     #$08
    bcc     :+
    cmp     #$0a  + $01
    bcs     :+
    lda     #$ff
    sta     star_position_y, x
:

    ; アニメーションの速度の変更
    lda     #%10000000
    sta     star_draw, x
    lda     #%11111111
    sta     star_erase, x

    ; 次の星へ
    inx
    cpx     #STAR_ENTRY
    bne     :--

    ; 終了
    rts

.endproc


; データの定義
;
.segment    "BSS"

; 星
;

; 位置
star_position_y:
    .res    STAR_ENTRY

; VRAM アドレス
star_vram_low:
    .res    STAR_ENTRY
star_vram_high:
    .res    STAR_ENTRY

; アニメーション
star_animation:
    .res    STAR_ENTRY

; 色
star_color:
    .res    STAR_ENTRY

; 描画
star_draw:
    .res    STAR_ENTRY
star_erase:
    .res    STAR_ENTRY
