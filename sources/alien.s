; alien.s - エイリアン
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
.include    "alien.inc"
.include    "bomb.inc"


; コードの定義
;
.segment    "APP"

; エイリアンを初期化する
;
.global _AlienInitialize
.proc   _AlienInitialize

    ; ジェネレータの初期化
    lda     alien_generate_interval
    sta     alien_generate

    ; エイリアンの初期化
    ldx     #$00
@init:

    ; 処理の設定
    lda     #<AlienEnter
    sta     alien_function_l, x
    lda     #>AlienEnter
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 生存の設定
;   lda     #$00
    sta     alien_alive, x

    ; 待機の設定
;   lda     #$00
    sta     alien_idle, x

    ; 位置の設定
;   lda     alien_position_x_start, x
;   lda     #$00
    sta     _alien_position_x, x
    sta     alien_last_x, x
;   lda     alien_position_y_start, x
    sta     _alien_position_y, x
    sta     alien_last_y, x

    ; 速度の設定
;   lda     #$00
    sta     alien_speed_x, x
    sta     alien_speed_x_maximum_plus, x
    sta     alien_speed_x_maximum_minus, x
    sta     alien_speed_y, x
    sta     alien_speed_y_maximum_plus, x
    sta     alien_speed_y_maximum_minus, x

    ; 加速度の設定
;   lda     #$00
    sta     alien_accel_x, x
    sta     alien_accel_x_interval, x
    sta     alien_accel_x_cycle, x
    sta     alien_accel_y, x
    sta     alien_accel_y_interval, x
    sta     alien_accel_y_cycle, x

    ; 描画の設定
;   lda     #$00
    sta     alien_render_erase, x
    sta     alien_render_draw, x

    ; アニメーションの設定
;   lda     #$00
    sta     alien_animation, x

    ; タイルセットの設定
;   lda     alien_tileset_idle_l, x
    sta     alien_tileset_l, x
;   lda     alien_tileset_idle_h, x
    sta     alien_tileset_h, x

    ; 次のエイリアンへ
    inx
    cpx     #ALIEN_ENTRY
    bne     @init

    ; 終了
    rts

.endproc

; エイリアンを更新する
;
.global _AlienUpdate
.proc   _AlienUpdate

    ; WORK
    ;   GAME_0_ALIEN_0..1

    ; ジェネレータの更新
    lda     _game + Game::play
    beq     @generate_end
    jsr     _ShipIsCollision
    and     #$ff
    beq     @generate_end
    lda     alien_generate
    beq     :+
    dec     alien_generate
    jmp     @generate_end
:

    ; アプローチを開始するエイリアンの取得
    jsr     _IocsGetRandomNumber
    and     #$0f
    cmp     #ALIEN_ENTRY
    bcc     :+
    sbc     #ALIEN_ENTRY
:
    tax
    ldy     #ALIEN_ENTRY
:
    lda     alien_idle, x
    bne     @generate_approach
    inx
    cpx     #ALIEN_ENTRY
    bne     :+
    ldx     #$00
:
    dey
    bne     :--
    jmp     @generate_end

    ; 待機の設定
@generate_approach:
    lda     #$00
    sta     alien_idle, x

    ; 処理の設定
    lda     #<AlienTurn
    sta     alien_function_l, x
    lda     #>AlienTurn
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; ジェネレータの再設定
    ldx     _game + Game::level
    lda     alien_generate_interval, x
    sta     alien_generate
@generate_end:

    ; エイリアンの走査
    ldx     #$00
@update:

    ; 処理の実行
    lda     #>(@next - $0001)
    pha
    lda     #<(@next - $0001)
    pha
    lda     alien_function_l, x
    sta     GAME_0_ALIEN_0
    lda     alien_function_h, x
    sta     GAME_0_ALIEN_1
    jmp     (GAME_0_ALIEN_0)

    ; 次のエイリアンへ
@next:
    inx
    cpx     #ALIEN_ENTRY
    bne     @update

    ; 終了
    rts

.endproc

; エイリアンを描画する
;
.global _AlienRender
.proc   _AlienRender

    ; WORK
    ;   GAME_0_ALIEN_0

    ; エイリアンの走査
    lda     #$00
    sta     GAME_0_ALIEN_0
@render:

    ; スプライトの消去
    ldx     GAME_0_ALIEN_0
    lda     alien_render_erase, x
    beq     :+
    lda     alien_last_x, x
    sta     @erase_arg + $0000
    lda     alien_last_y, x
    sta     @erase_arg + $0001
    ldx     #<@erase_arg
    lda     #>@erase_arg
    jsr     _LibErase14x14Sprite
:

    ; スプライトの描画
    ldx     GAME_0_ALIEN_0
    lda     alien_render_draw, x
    beq     :+
    lda     _alien_position_x, x
    sta     @draw_arg + $0000
    lda     _alien_position_y, x
    sta     @draw_arg + $0001
    lda     alien_tileset_l, x
    sta     @draw_arg + $0002
    lda     alien_tileset_h, x
    sta     @draw_arg + $0003
    ldx     #<@draw_arg
    lda     #>@draw_arg
    jsr     _LibDraw14x14Sprite
:

    ; 描画の更新
    ldx     GAME_0_ALIEN_0
    lda     #$00
    sta     alien_render_draw, x
    sta     alien_render_erase, x

    ; 次のエイリアンへ
    inc     GAME_0_ALIEN_0
    lda     GAME_0_ALIEN_0
    cmp     #ALIEN_ENTRY
    bne     @render

    ; 終了
    rts

; スプライト
@erase_arg:
@draw_arg:
    .byte   $00, $00
    .word   $0000

.endproc

; エイリアンが登場する
;
.proc   AlienEnter

    ; IN
    ;   x = エイリアンの参照

    ; 初期化
    lda     alien_state, x
    bne     @initialized

    ; 生存の設定
    lda     #$01
    sta     alien_alive, x

    ; 待機の設定
    lda     #$00
    sta     alien_idle, x

    ; 位置の設定
    lda     alien_position_x_start, x
    sta     _alien_position_x, x
    sta     alien_last_x, x
    lda     alien_position_y_start, x
    sec
    sbc     #$1c
    sta     _alien_position_y, x
    sta     alien_last_y, x

    ; タイルセットの設定
    lda     alien_tileset_down_l, x
    sta     alien_tileset_l, x
    lda     alien_tileset_down_h, x
    sta     alien_tileset_h, x

    ; 初期化の完了
    inc     alien_state, x
@initialized:

    ; 位置の保存
    jsr     AlienStorePosition

    ; 移動
    inc     _alien_position_y, x
    inc     _alien_position_y, x

    ; 描画の更新
    jsr     AlienSetRender

    ; 移動の完了
    lda     _alien_position_y, x
    cmp     alien_position_y_start, x
    bne     @end

    ; 処理の設定
    lda     #<AlienIdle
    sta     alien_function_l, x
    lda     #>AlienIdle
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 終了
@end:
    rts

.endproc

; エイリアンが待機する
;
.proc   AlienIdle

    ; IN
    ;   x = エイリアンの参照
    ; WORK
    ;   GAME_0_ALIEN_0

    ; 初期化
    lda     alien_state, x
    bne     @initialized

    ; 待機の設定
    lda     #$01
    sta     alien_idle, x

    ; アニメーションの設定
    lda     #$00
    sta     alien_animation, x

    ; 初期化の完了
    inc     alien_state, x
@initialized:

    ; 位置の保存
    jsr     AlienStorePosition

    ; タイルセットの設定
    lda     alien_animation, x
    and     #$02
    bne     :+
    lda     alien_tileset_idle_0_l, x
    sta     alien_tileset_l, x
    lda     alien_tileset_idle_0_h, x
    sta     alien_tileset_h, x
    jmp     :++
:
    lda     alien_tileset_idle_1_l, x
    sta     alien_tileset_l, x
    lda     alien_tileset_idle_1_h, x
    sta     alien_tileset_h, x
:
    
    ; アニメーションの更新
    inc     alien_animation, x

    ; 描画の更新
    jsr     AlienSetRender

    ; 待機の完了
.if 0
    lda     IOCS_0_KEYCODE
    sec
    sbc     #'A'
    cmp     #ALIEN_ENTRY
    bcs     @end
    sta     GAME_0_ALIEN_0
    cpx     GAME_0_ALIEN_0
    bne     @end

    ; 待機の設定
    lda     #$00
    sta     alien_idle, x

    ; 処理の設定
    lda     #<AlienTurn
    sta     alien_function_l, x
    lda     #>AlienTurn
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x
.endif

    ; 終了
@end:
    rts

.endproc

; エイリアンがターンする
;
.proc   AlienTurn

    ; IN
    ;   x = エイリアンの参照

    ; 初期化
    lda     alien_state, x
    bne     @initialized

    ; 速度の設定
    lda     #$00
    sta     alien_speed_x, x
    lda     #$fc
    sta     alien_speed_y, x
    lda     #$04
    sta     alien_speed_x_maximum_plus, x
    lda     #$03
    sta     alien_speed_y_maximum_plus, x
    lda     #$fc
    sta     alien_speed_x_maximum_minus, x
    sta     alien_speed_y_maximum_minus, x

    ; 加速度の設定
    jsr     _ShipGetPositionX
    cmp     _alien_position_x, x
    bcc     :+
    lda     #$ff
    jmp     :++
:
    lda     #$01
:
    sta     alien_accel_x, x
    lda     #$00
    sta     alien_accel_x_interval, x
    sta     alien_accel_x_cycle, x
    lda     #$01
    sta     alien_accel_y, x
    lda     #$00
    sta     alien_accel_y_interval, x
    sta     alien_accel_y_cycle, x

    ; タイルセットの設定
    lda     alien_tileset_up_l, x
    sta     alien_tileset_l, x
    lda     alien_tileset_up_h, x
    sta     alien_tileset_h, x

    ; 初期化の完了
    inc     alien_state, x
@initialized:

    ; 位置の保存
    jsr     AlienStorePosition

    ; 移動
    jsr     AlienMove

    ; 描画の更新
    jsr     AlienSetRender

    ; Y 速度の監視
    lda     alien_speed_y, x
    bne     :+
    lda     alien_accel_x, x
    eor     #$ff
    clc
    adc     #$01
    sta     alien_accel_x, x
:

    ; X 速度の監視
    lda     alien_speed_x, x
    bne     :+
    sta     alien_accel_x, x
    lda     #$ff
    sta     alien_accel_y, x
    inc     alien_state, x
:

    ; ターンの完了
    lda     alien_state, x
    cmp     #$02
    bne     @end

    ; 処理の設定
    lda     #<AlienApproach
    sta     alien_function_l, x
    lda     #>AlienApproach
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 終了
@end:
    rts

.endproc

; エイリアンがアプローチする
;
.proc   AlienApproach

    ; IN
    ;   x = エイリアンの参照

    ; 初期化
    lda     alien_state, x
    bne     @initialized

    ; 速度の設定
    lda     alien_speed_x_maximum_approach, x
    sta     alien_speed_x_maximum_plus, x
    eor     #$ff
    clc
    adc     #$01
    sta     alien_speed_x_maximum_minus, x

    ; 加速度の設定
    jsr     _ShipGetPositionX
    cmp     _alien_position_x, x
    bcs     :+
    lda     #$ff
    jmp     :++
:
    lda     #$01
:
    sta     alien_accel_x, x
    lda     #$00
    sta     alien_accel_x_interval, x
    lda     alien_accel_x_cycle_approach, x
    sta     alien_accel_x_cycle, x
    lda     #$01
    sta     alien_accel_y, x
    lda     #$00
    sta     alien_accel_y_interval, x
    sta     alien_accel_y_cycle, x

    ; アプローチの回数の設定
    lda     alien_approach_maximum, x
    sta     alien_approach, x

    ; 初期化の完了
    inc     alien_state, x
@initialized:

    ; 位置の保存
    jsr     AlienStorePosition

    ; 移動
    jsr     AlienMove

    ; 加速度の更新
    lda     alien_accel_x, x
    beq     @accel_end
    bpl     @accel_plus
@accel_minus:
    jsr     _ShipGetPositionX
    cmp     _alien_position_x, x
    bcc     @accel_end
    lda     alien_approach, x
    beq     :+
    dec     alien_approach, x
    lda     #$01
:
    sta     alien_accel_x, x
    jmp     @accel_end
@accel_plus:
    jsr     _ShipGetPositionX
    cmp     _alien_position_x, x
    bcs     @accel_end
    lda     alien_approach, x
    beq     :+
    lda     #$ff
:
    sta     alien_accel_x, x
;   jmp     @accel_end
@accel_end:

    ; 描画の更新
    jsr     AlienSetRender

    ; アプローチの完了
    jsr     AlienIsView
    and     #$ff
    bne     @end

    ; エイリアンを外に出す
    jsr     _AlienSetOut

    ; 終了
@end:
    rts

.endproc

; エイリアンが爆発する
;
.proc   AlienBomb

    ; IN
    ;   x = エイリアンの参照

    ; 初期化
    lda     alien_state, x
    bne     @initialized

    ; アニメーションの設定
    lda     #$00
    sta     alien_animation, x

    ; シップに近いと撃たない
    lda     _alien_position_y, x
    cmp     #$44
    bcs     @bullet_end

    ; 敵弾の生成
    lda     #$00
    sta     GAME_0_ALIEN_0
    lda     _game + Game::level
    sta     GAME_0_ALIEN_1
:
    ldy     GAME_0_ALIEN_0
    lda     _alien_position_x, x
    clc
    adc     @bullet_position_x, y
    sta     @bullet_arg + $0000
    lda     _alien_position_y, x
    clc
    adc     @bullet_position_y, y
    sta     @bullet_arg + $0001
    lda     @bullet_color, y
    bne     :+
    lda     alien_color_0, x
    jmp     :++
:
    lda     alien_color_1, x
:
    sta     @bullet_arg + $0006
    ldy     GAME_0_ALIEN_1
    lda     @bullet_speed_x_d, y
    sta     @bullet_arg + $0002
    lda     @bullet_speed_x, y
    sta     @bullet_arg + $0003
    lda     @bullet_speed_y_d, y
    sta     @bullet_arg + $0004
    lda     @bullet_speed_y, y
    sta     @bullet_arg + $0005
    txa
    pha
    ldx     #<@bullet_arg
    lda     #>@bullet_arg
    jsr     _BulletShoot
    pla
    tax
    lda     GAME_0_ALIEN_1
    clc
    adc     #GAME_LEVEL_SIZE
    sta     GAME_0_ALIEN_1
    inc     GAME_0_ALIEN_0
    lda     GAME_0_ALIEN_0
    ldy     _game + Game::level
    cmp     @bullet_entry, y
    bne     :---
@bullet_end:

    ; 初期化の完了
    inc     alien_state, x
@initialized:

    ; 位置の保存
    jsr     AlienStorePosition

    ; タイルセットの設定
    lda     alien_animation, x
    tay
    lda     alien_tileset_bomb_l, y
    sta     alien_tileset_l, x
    lda     alien_tileset_bomb_h, y
    sta     alien_tileset_h, x
    
    ; アニメーションの更新
    inc     alien_animation, x

    ; 描画の更新
    jsr     AlienSetRender

    ; 爆発の完了
    lda     alien_animation, x
    cmp     #(BOMB_SIZE * $03)
    bcc     @end

    ; 描画の更新
    lda     #$00
    sta     alien_render_draw, x
    lda     #$01
    sta     alien_render_erase, x

    ; エイリアンを外に出す
    jsr     _AlienSetOut

    ; 終了
@end:
    rts

; 敵弾
@bullet_arg:
    .byte   $00, $00
    .byte   $00, $00, $00, $00
    .byte   $00
@bullet_entry:
    .byte   $03
    .byte   $03
    .byte   $05
    .byte   $05
    .byte   $05
@bullet_position_x:
    .byte   $01
    .byte   $00
    .byte   $02
    .byte   $00
    .byte   $02
@bullet_position_y:
    .byte   $03
    .byte   $01
    .byte   $01
    .byte   $02
    .byte   $02
@bullet_speed_x_d:
    .byte   <( $01c0 *   0 / $0100), <( $0200 *   0 / $0100), <( $0200 *   0 / $0100), <( $0240 *   0 / $0100), <( $0280 *   0 / $0100)
    .byte   <(-$01c0 * 108 / $0100), <(-$0200 * 108 / $0100), <(-$0200 * 108 / $0100), <(-$0240 * 108 / $0100), <(-$0280 * 108 / $0100)
    .byte   <( $01c0 * 108 / $0100), <( $0200 * 108 / $0100), <( $0200 * 108 / $0100), <( $0240 * 108 / $0100), <( $0280 * 108 / $0100)
    .byte   <(-$0150 *  55 / $0100), <(-$0180 *  55 / $0100), <(-$0180 *  55 / $0100), <(-$01b0 *  55 / $0100), <(-$01e0 *  55 / $0100)
    .byte   <( $0150 *  55 / $0100), <( $0180 *  55 / $0100), <( $0180 *  55 / $0100), <( $01b0 *  55 / $0100), <( $01e0 *  55 / $0100)
@bullet_speed_x:
    .byte   >( $01c0 *   0 / $0100), >( $0200 *   0 / $0100), >( $0200 *   0 / $0100), >( $0240 *   0 / $0100), >( $0280 *   0 / $0100)
    .byte   >(-$01c0 * 108 / $0100), >(-$0200 * 108 / $0100), >(-$0200 * 108 / $0100), >(-$0240 * 108 / $0100), >(-$0280 * 108 / $0100)
    .byte   >( $01c0 * 108 / $0100), >( $0200 * 108 / $0100), >( $0200 * 108 / $0100), >( $0240 * 108 / $0100), >( $0280 * 108 / $0100)
    .byte   >(-$0150 *  55 / $0100), >(-$0180 *  55 / $0100), >(-$0180 *  55 / $0100), >(-$01b0 *  55 / $0100), >(-$01e0 *  55 / $0100)
    .byte   >( $0150 *  55 / $0100), >( $0180 *  55 / $0100), >( $0180 *  55 / $0100), >( $01b0 *  55 / $0100), >( $01e0 *  55 / $0100)
@bullet_speed_y_d:
    .byte   <( $01c0 * 256 / $0100), <( $0200 * 256 / $0100), <( $0200 * 256 / $0100), <( $0240 * 256 / $0100), <( $0280 * 256 / $0100)
    .byte   <( $01c0 * 232 / $0100), <( $0200 * 232 / $0100), <( $0200 * 232 / $0100), <( $0240 * 232 / $0100), <( $0280 * 232 / $0100)
    .byte   <( $01c0 * 232 / $0100), <( $0200 * 232 / $0100), <( $0200 * 232 / $0100), <( $0240 * 232 / $0100), <( $0280 * 232 / $0100)
    .byte   <( $0150 * 250 / $0100), <( $0180 * 250 / $0100), <( $0180 * 250 / $0100), <( $01b0 * 250 / $0100), <( $01e0 * 250 / $0100)
    .byte   <( $0150 * 250 / $0100), <( $0180 * 250 / $0100), <( $0180 * 250 / $0100), <( $01b0 * 250 / $0100), <( $01e0 * 250 / $0100)
@bullet_speed_y:
    .byte   >( $01c0 * 256 / $0100), >( $0200 * 256 / $0100), >( $0200 * 256 / $0100), >( $0240 * 256 / $0100), >( $0280 * 256 / $0100)
    .byte   >( $01c0 * 232 / $0100), >( $0200 * 232 / $0100), >( $0200 * 232 / $0100), >( $0240 * 232 / $0100), >( $0280 * 232 / $0100)
    .byte   >( $01c0 * 232 / $0100), >( $0200 * 232 / $0100), >( $0200 * 232 / $0100), >( $0240 * 232 / $0100), >( $0280 * 232 / $0100)
    .byte   >( $0150 * 250 / $0100), >( $0180 * 250 / $0100), >( $0180 * 250 / $0100), >( $01b0 * 250 / $0100), >( $01e0 * 250 / $0100)
    .byte   >( $0150 * 250 / $0100), >( $0180 * 250 / $0100), >( $0180 * 250 / $0100), >( $01b0 * 250 / $0100), >( $01e0 * 250 / $0100)
@bullet_color:
    .byte   $00
    .byte   $00
    .byte   $00
    .byte   $01
    .byte   $01

.endproc

; エイリアンが外で待つ
;
.proc   AlienOut

    ; IN
    ;   x = エイリアンの参照

;   ; 初期化
;   lda     alien_state, x
;   bne     @initialized
;
;   ; 初期化の完了
;   inc     alien_state, x
;@initialized:

    ; 状態の更新
    inc     alien_state, x
    lda     alien_state, x
    cmp     #$40
    bcc     @end

    ; 処理の設定
    lda     #<AlienEnter
    sta     alien_function_l, x
    lda     #>AlienEnter
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 終了
@end:
    rts

.endproc

; エイリアンがアクティブかどうかを判定する
;
.global _AlienIsActive
.proc   _AlienIsActive

    ; IN
    ;   x = エイリアンの参照
    ; OUT
    ;   a = !0..アクティブ

    ; エイリアンの生存
    lda     alien_alive, x
    bne     :+
    rts
:

.endproc

; エイリアンが画面内にいるかどうかを判定する
;
.proc AlienIsView

    ; IN
    ;   x = エイリアンの参照
    ; OUT
    ;   a = !0..画面内にいる

    ; X 位置の判定
    lda     _alien_position_x, x
    clc
    adc     #$06
    cmp     #($06 + $70)
    bcs     @out

    ; Y 位置の判定
    lda     _alien_position_y, x
    clc
    adc     #$06
    cmp     #($06 + $60)
    bcs     @out

    ; 画面内
    lda     #$01
    jmp     @end

    ; 画面外
@out:
    lda     #$00

    ; 終了
@end:
    rts

.endproc

; エイリアンの位置を保存する　
;
.proc   AlienStorePosition

    ; IN
    ;   x = エイリアンの参照

    ; 位置の保存
    lda     _alien_position_x, x
    sta     alien_last_x, x
    lda     _alien_position_y, x
    sta     alien_last_y, x

    ; 終了
    rts

.endproc

; エイリアンを移動する
;
.proc   AlienMove

    ; IN
    ;   x = エイリアンの参照

    ; 移動
    lda     alien_speed_x, x
    clc
    adc     _alien_position_x, x
    sta     _alien_position_x, x
    lda     alien_speed_y, x
    clc
    adc     _alien_position_y, x
    sta     _alien_position_y, x

    ; X 速度の更新
    lda     alien_accel_x_cycle, x
    beq     :+
    clc
    adc     alien_accel_x_interval, x
    sta     alien_accel_x_interval, x
    bcc     @speed_x_end
    lda     #$00
    sta     alien_accel_x_interval, x
:
    lda     alien_accel_x, x
    clc
    adc     alien_speed_x, x
    bpl     :+
    cmp     alien_speed_x_maximum_minus, x
    bcs     :++
    lda     alien_speed_x_maximum_minus, x
    jmp     :++
:
    cmp     alien_speed_x_maximum_plus, x
    bcc     :+
    lda     alien_speed_x_maximum_plus, x
;   jmp     :+
:
    sta     alien_speed_x, x
@speed_x_end:

    ; Y 速度の更新
    lda     alien_accel_y_cycle, x
    beq     :+
    clc
    adc     alien_accel_y_interval, x
    sta     alien_accel_y_interval, x
    bne     @speed_y_end
:
    lda     alien_accel_y, x
    clc
    adc     alien_speed_y, x
    sta     alien_speed_y, x
    bmi     :+
    cmp     alien_speed_y_maximum_plus, x
    bcc     :+
    lda     alien_accel_y, x
    bmi     :+
    lda     alien_speed_y_maximum_plus, x
    sta     alien_speed_y, x
:
@speed_y_end:
    
    ; 終了
@end:
    rts

.endproc

; エイリアンの描画を設定する
;
.proc   AlienSetRender

    ; IN
    ;   x = エイリアンの参照

    ; 描画の設定
    lda     _alien_position_x, x
    cmp     alien_last_x, x
    bne     :+
    lda     _alien_position_y, x
    cmp     alien_last_y, x
    beq     :++
:
    lda     #$01
    sta     alien_render_erase, x
:
    lda     #$01
    sta     alien_render_draw, x

    ; 終了
    rts

.endproc

; エイリアンを爆発させる
;
.global _AlienSetBomb
.proc   _AlienSetBomb

    ; IN
    ;   x = エイリアンの参照

    ; 生存の設定
    lda     #$00
    sta     alien_alive, x

    ; 処理の設定
    lda     #<AlienBomb
    sta     alien_function_l, x
    lda     #>AlienBomb
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 終了
    rts

.endproc

; エイリアンを外に出す
;
.global _AlienSetOut
.proc   _AlienSetOut

    ; IN
    ;   x = エイリアンの参照

    ; 生存の設定
    lda     #$00
    sta     alien_alive, x

    ; 処理の設定
    lda     #<AlienOut
    sta     alien_function_l, x
    lda     #>AlienOut
    sta     alien_function_h, x

    ; 状態の設定
    lda     #$00
    sta     alien_state, x

    ; 終了
    rts

.endproc

; ジェネレータ
;
alien_generate_interval:
    .byte   $50, $40, $30, $20, $10

; 位置
;
alien_position_x_start:
    .byte   $29, $3f, $1e, $29, $34, $3f, $4a, $24, $2f, $3a, $45
alien_position_y_start:
    .byte   $04, $04, $10, $10, $10, $10, $10, $1c, $1c, $1c, $1c

; 速度
;
alien_speed_x_maximum_approach:
    .byte   $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04

; 加速度
;
alien_accel_x_cycle_approach:
    .byte   $00, $00, $80, $60, $60, $60, $80, $40, $40, $40, $40

; アプローチの回数
alien_approach_maximum:
    .byte   $10, $10, $01, $00, $00, $00, $01, $00, $00, $00, $00

; スコア
.global _alien_score
_alien_score:
    .byte   $05, $05, $03, $02, $02, $02, $03, $01, $01, $01, $01

; 色
alien_color_0:
    .byte   $02, $02, $00, $01, $01, $01, $00, $03, $03, $03, $03
alien_color_1:
    .byte   $02, $02, $02, $00, $00, $00, $02, $03, $03, $03, $03

; タイルセット
;
alien_tileset_a_up_0:
alien_tileset_a_up_1:
    .incbin     "resources/sprites/alien-a_up.ptn"
alien_tileset_a_down:
    .incbin     "resources/sprites/alien-a_down.ptn"
;alien_tileset_a_left:
;   .incbin     "resources/sprites/alien-a_left.ptn"
;alien_tileset_a_right:
;   .incbin     "resources/sprites/alien-a_right.ptn"
alien_tileset_b_up_0:
    .incbin     "resources/sprites/alien-b_up0.ptn"
alien_tileset_b_up_1:
    .incbin     "resources/sprites/alien-b_up1.ptn"
alien_tileset_b_down:
    .incbin     "resources/sprites/alien-b_down.ptn"
;alien_tileset_b_left:
;   .incbin     "resources/sprites/alien-b_left.ptn"
;alien_tileset_b_right:
;   .incbin     "resources/sprites/alien-b_right.ptn"
alien_tileset_c_up_0:
    .incbin     "resources/sprites/alien-c_up0.ptn"
alien_tileset_c_up_1:
    .incbin     "resources/sprites/alien-c_up1.ptn"
alien_tileset_c_down:
    .incbin     "resources/sprites/alien-c_down.ptn"
;alien_tileset_c_left:
;   .incbin     "resources/sprites/alien-c_left.ptn"
;alien_tileset_c_right:
;   .incbin     "resources/sprites/alien-c_right.ptn"
alien_tileset_d_up_0:
    .incbin     "resources/sprites/alien-d_up0.ptn"
alien_tileset_d_up_1:
    .incbin     "resources/sprites/alien-d_up1.ptn"
alien_tileset_d_down:
    .incbin     "resources/sprites/alien-d_down.ptn"
;alien_tileset_d_left:
;   .incbin     "resources/sprites/alien-d_left.ptn"
;alien_tileset_d_right:
;   .incbin     "resources/sprites/alien-d_right.ptn"

; 待機
alien_tileset_up_l:
alien_tileset_idle_0_l:
    .byte   <alien_tileset_a_up_0
    .byte   <alien_tileset_a_up_0
    .byte   <alien_tileset_b_up_0
    .byte   <alien_tileset_c_up_0
    .byte   <alien_tileset_c_up_0
    .byte   <alien_tileset_c_up_0
    .byte   <alien_tileset_b_up_0
    .byte   <alien_tileset_d_up_0
    .byte   <alien_tileset_d_up_0
    .byte   <alien_tileset_d_up_0
    .byte   <alien_tileset_d_up_0
alien_tileset_up_h:
alien_tileset_idle_0_h:
    .byte   >alien_tileset_a_up_0
    .byte   >alien_tileset_a_up_0
    .byte   >alien_tileset_b_up_0
    .byte   >alien_tileset_c_up_0
    .byte   >alien_tileset_c_up_0
    .byte   >alien_tileset_c_up_0
    .byte   >alien_tileset_b_up_0
    .byte   >alien_tileset_d_up_0
    .byte   >alien_tileset_d_up_0
    .byte   >alien_tileset_d_up_0
    .byte   >alien_tileset_d_up_0
alien_tileset_idle_1_l:
    .byte   <alien_tileset_a_up_1
    .byte   <alien_tileset_a_up_1
    .byte   <alien_tileset_b_up_1
    .byte   <alien_tileset_c_up_1
    .byte   <alien_tileset_c_up_1
    .byte   <alien_tileset_c_up_1
    .byte   <alien_tileset_b_up_1
    .byte   <alien_tileset_d_up_1
    .byte   <alien_tileset_d_up_1
    .byte   <alien_tileset_d_up_1
    .byte   <alien_tileset_d_up_1
alien_tileset_idle_1_h:
    .byte   >alien_tileset_a_up_1
    .byte   >alien_tileset_a_up_1
    .byte   >alien_tileset_b_up_1
    .byte   >alien_tileset_c_up_1
    .byte   >alien_tileset_c_up_1
    .byte   >alien_tileset_c_up_1
    .byte   >alien_tileset_b_up_1
    .byte   >alien_tileset_d_up_1
    .byte   >alien_tileset_d_up_1
    .byte   >alien_tileset_d_up_1
    .byte   >alien_tileset_d_up_1

; 下向き
alien_tileset_down_l:
    .byte   <alien_tileset_a_down
    .byte   <alien_tileset_a_down
    .byte   <alien_tileset_b_down
    .byte   <alien_tileset_c_down
    .byte   <alien_tileset_c_down
    .byte   <alien_tileset_c_down
    .byte   <alien_tileset_b_down
    .byte   <alien_tileset_d_down
    .byte   <alien_tileset_d_down
    .byte   <alien_tileset_d_down
    .byte   <alien_tileset_d_down
alien_tileset_down_h:
    .byte   >alien_tileset_a_down
    .byte   >alien_tileset_a_down
    .byte   >alien_tileset_b_down
    .byte   >alien_tileset_c_down
    .byte   >alien_tileset_c_down
    .byte   >alien_tileset_c_down
    .byte   >alien_tileset_b_down
    .byte   >alien_tileset_d_down
    .byte   >alien_tileset_d_down
    .byte   >alien_tileset_d_down
    .byte   >alien_tileset_d_down

; 爆発
alien_tileset_bomb_l:
    .byte   <_bomb_tileset_a_0
    .byte   <_bomb_tileset_a_0
    .byte   <_bomb_tileset_a_0
    .byte   <_bomb_tileset_a_1
    .byte   <_bomb_tileset_a_1
    .byte   <_bomb_tileset_a_1
    .byte   <_bomb_tileset_a_2
    .byte   <_bomb_tileset_a_2
    .byte   <_bomb_tileset_a_2
alien_tileset_bomb_h:
    .byte   >_bomb_tileset_a_0
    .byte   >_bomb_tileset_a_0
    .byte   >_bomb_tileset_a_0
    .byte   >_bomb_tileset_a_1
    .byte   >_bomb_tileset_a_1
    .byte   >_bomb_tileset_a_1
    .byte   >_bomb_tileset_a_2
    .byte   >_bomb_tileset_a_2
    .byte   >_bomb_tileset_a_2


; データの定義
;
.segment    "BSS"

; ジェネレータ
;
alien_generate:
    .res    $01

; エイリアン
;

; 処理
alien_function_l:
    .res    ALIEN_ENTRY
alien_function_h:
    .res    ALIEN_ENTRY

; 状態
alien_state:
    .res    ALIEN_ENTRY

; 生存
alien_alive:
    .res    ALIEN_ENTRY

; 待機
alien_idle:
    .res    ALIEN_ENTRY

; 位置
.global _alien_position_x
_alien_position_x:
    .res    ALIEN_ENTRY
.global _alien_position_y
_alien_position_y:
    .res    ALIEN_ENTRY

; 直前の位置
alien_last_x:
    .res    ALIEN_ENTRY
alien_last_y:
    .res    ALIEN_ENTRY

; 速度
alien_speed_x:
    .res    ALIEN_ENTRY
alien_speed_x_maximum_plus:
    .res    ALIEN_ENTRY
alien_speed_x_maximum_minus:
    .res    ALIEN_ENTRY
alien_speed_y:
    .res    ALIEN_ENTRY
alien_speed_y_maximum_plus:
    .res    ALIEN_ENTRY
alien_speed_y_maximum_minus:
    .res    ALIEN_ENTRY

; 加速度
alien_accel_x:
    .res    ALIEN_ENTRY
alien_accel_x_interval:
    .res    ALIEN_ENTRY
alien_accel_x_cycle:
    .res    ALIEN_ENTRY
alien_accel_y:
    .res    ALIEN_ENTRY
alien_accel_y_interval:
    .res    ALIEN_ENTRY
alien_accel_y_cycle:
    .res    ALIEN_ENTRY

; アプローチの回数
alien_approach:
    .res        ALIEN_ENTRY

; 描画
alien_render_draw:
    .res    ALIEN_ENTRY
alien_render_erase:
    .res    ALIEN_ENTRY

; アニメーション
alien_animation:
    .res    ALIEN_ENTRY

; タイルセット
alien_tileset_l:
    .res    ALIEN_ENTRY
alien_tileset_h:
    .res    ALIEN_ENTRY
