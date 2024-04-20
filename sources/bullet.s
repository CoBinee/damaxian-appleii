; bullet.s - 敵弾
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
.include    "bullet.inc"


; コードの定義
;
.segment    "APP"

; 敵弾を初期化する
;
.global _BulletInitialize
.proc   _BulletInitialize

    ; 敵弾の初期化
    ldx     #$00
@init:

    ; 状態の設定
    lda     #$00
    sta     _bullet_state, x

    ; 次の敵弾へ
    inx
    cpx     #BULLET_ENTRY
    bne     @init

    ; 終了
    rts

.endproc

; 敵弾を更新する
;
.global _BulletUpdate
.proc   _BulletUpdate

    ; 敵弾の走査
    ldx     #$00
@update:

    ; 敵弾の存在
    lda     _bullet_state, x
    beq     @next

    ; X 位置の保存
    lda     _bullet_position_x, x
    sta     bullet_last_x, x
    clc
    adc     #$03
    cmp     #($03 + $70)
    bcs     @kill

    ; Y 位置の保存
    lda     _bullet_position_y, x
    sta     bullet_last_y, x
    clc
    adc     #$03
    cmp     #($03 + $60)
    bcs     @kill

    ; 移動
    lda     bullet_speed_x_d, x
    clc
    adc     bullet_position_x_d, x
    sta     bullet_position_x_d, x
    lda     bullet_speed_x, x
    adc     _bullet_position_x, x
    sta     _bullet_position_x, x
    lda     bullet_speed_y_d, x
    clc
    adc     bullet_position_y_d, x
    sta     bullet_position_y_d, x
    lda     bullet_speed_y, x
    adc     _bullet_position_y, x
    sta     _bullet_position_y, x
    jmp     @next

    ; 削除
@kill:
    lda     #$00
    sta     _bullet_state, x

    ; 次の敵弾へ
@next:
    inx
    cpx     #BULLET_ENTRY
    bne     @update

    ; 終了
    rts

.endproc

; 敵弾を描画する
;
.global _BulletRender
.proc   _BulletRender

    ; WORK
    ;   GAME_0_WORK_0..1

    ; 敵弾の走査
    lda     #$00
    sta     GAME_0_WORK_0
@render:

    ; 状態の設定
    ldx     GAME_0_WORK_0
    lda     _bullet_state, x
    beq     @wait

    ; スプライトの消去
;   ldx     GAME_0_WORK_0
    lda     bullet_last_x, x
    sta     @erase_arg + $0000
    lda     bullet_last_y, x
    sta     @erase_arg + $0001
    ldx     #<@erase_arg
    lda     #>@erase_arg
    jsr     _LibErase8x8Sprite

    ; スプライトの描画
    ldx     GAME_0_WORK_0
    lda     _bullet_position_x, x
    sta     @draw_arg + $0000
    lda     _bullet_position_y, x
    sta     @draw_arg + $0001
    asl     a
    sta     GAME_0_WORK_1
    lda     bullet_color, x
    tay
    lda     bullet_tileset_l, y
    sta     @draw_arg + $0002
    lda     bullet_tileset_h, y
    sta     @draw_arg + $0003
    ldx     #<@draw_arg
    lda     #>@draw_arg
    jsr     _LibDraw8x8Sprite
    jmp     @next

    ; 待機
@wait:
    lda     #$03
    jsr     _LibWaitTileset

    ; 次の敵弾へ
@next:
    inc     GAME_0_WORK_0
    lda     GAME_0_WORK_0
    cmp     #BULLET_ENTRY
    beq     :+
    jmp     @render
:

    ; 終了
    rts

; スプライト
@erase_arg:
@draw_arg:
    .byte   $00, $00
    .word   $0000

.endproc

; 敵弾を撃つ
;
.global _BulletShoot
.proc   _BulletShoot

    ; IN
    ;   ax[0] = X 位置
    ;   ax[1] = Y 位置
    ;   ax[2] = X 速度（小数部）
    ;   ax[3] = X 速度（整数部）
    ;   ax[4] = Y 速度（小数部）
    ;   ax[5] = Y 速度（整数部）
    ;   ax[6] = 色
    ; WORK
    ;   GAME_0_WORK_0..1

    ; 位置の保存
    stx     GAME_0_WORK_0
    sta     GAME_0_WORK_1

    ; 敵弾の取得
    ldx     #$00
:
    lda     _bullet_state, x
    beq     @entry
    inx
    cpx     #BULLET_ENTRY
    bne     :-
    rts

    ; 敵弾の登録
@entry:

    ; 状態の設定
    lda     #$01
    sta     _bullet_state, x

    ; 位置の設定
    ldy     #$00
    lda     (GAME_0_WORK_0), y
    sta     _bullet_position_x, x
    sta     bullet_last_x, x
    iny
    lda     (GAME_0_WORK_0), y
    sta     _bullet_position_y, x
    sta     bullet_last_y, x
    lda     #$00
    sta     bullet_position_x_d, x
    sta     bullet_position_y_d, x

    ; 速度の設定
;   ldy     #$02
    iny
    lda     (GAME_0_WORK_0), y
    sta     bullet_speed_x_d, x
    iny
    lda     (GAME_0_WORK_0), y
    sta     bullet_speed_x, x
    iny
    lda     (GAME_0_WORK_0), y
    sta     bullet_speed_y_d, x
    iny
    lda     (GAME_0_WORK_0), y
    sta     bullet_speed_y, x

    ; 色の設定
;   ldy     #$06
    iny
    lda     (GAME_0_WORK_0), y
    sta     bullet_color, x

    ; 終了
    rts

.endproc

; タイルセット
;
bullet_tileset_0:
    .incbin     "resources/sprites/bullet-green.ptn"
bullet_tileset_1:
    .incbin     "resources/sprites/bullet-purple.ptn"
bullet_tileset_2:
    .incbin     "resources/sprites/bullet-orange.ptn"
bullet_tileset_3:
    .incbin     "resources/sprites/bullet-blue.ptn"
bullet_tileset_l:
    .byte       <bullet_tileset_0
    .byte       <bullet_tileset_1
    .byte       <bullet_tileset_2
    .byte       <bullet_tileset_3
bullet_tileset_h:
    .byte       >bullet_tileset_0
    .byte       >bullet_tileset_1
    .byte       >bullet_tileset_2
    .byte       >bullet_tileset_3


; データの定義
;
.segment    "BSS"

; 敵弾
;

; 状態
.global _bullet_state
_bullet_state:
    .res    BULLET_ENTRY

; 位置
bullet_position_x_d:
    .res    BULLET_ENTRY
.global _bullet_position_x
_bullet_position_x:
    .res    BULLET_ENTRY
bullet_position_y_d:
    .res    BULLET_ENTRY
.global _bullet_position_y
_bullet_position_y:
    .res    BULLET_ENTRY

; 直前の位置
bullet_last_x:
    .res    BULLET_ENTRY
bullet_last_y:
    .res    BULLET_ENTRY

; 速度
bullet_speed_x_d:
    .res    BULLET_ENTRY
bullet_speed_x:
    .res    BULLET_ENTRY
bullet_speed_y_d:
    .res    BULLET_ENTRY
bullet_speed_y:
    .res    BULLET_ENTRY

; 色
bullet_color:
    .res    BULLET_ENTRY
