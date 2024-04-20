; ship.s - シップ
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
.include    "field.inc"
.include    "game.inc"
.include    "ship.inc"
.include    "bomb.inc"


; コードの定義
;
.segment    "APP"

; シップを初期化する
;
.global _ShipInitialize
.proc   _ShipInitialize

    ; 0 クリア
    ldx     #$00
    lda     #$00
:
    sta     _ship, x
    inx
    cpx     #(.sizeof(Ship))
    bne     :-

    ; 処理の設定
    lda     #<ShipPlay
    sta     _ship + Ship::function_l
    lda     #>ShipPlay
    sta     _ship + Ship::function_h

    ; 終了
    rts

.endproc

; シップを更新する
;
.global _ShipUpdate
.proc   _ShipUpdate

    ; WORK
    ;   GAME_0_SHIP_0..1

    ; 処理の実行
    lda     _ship + Ship::function_l
    sta     GAME_0_SHIP_0
    lda     _ship + Ship::function_h
    sta     GAME_0_SHIP_1
    jmp     (GAME_0_SHIP_0)

.endproc

; シップを描画する
;
.global _ShipRender
.proc   _ShipRender

    ; スプライトの消去
    lda     _ship + Ship::render_erase
    beq     :+
    lda     _ship + Ship::last_x
    sta     @erase_arg + $0000
    lda     _ship + Ship::last_y
    sta     @erase_arg + $0001
    ldx     #<@erase_arg
    lda     #>@erase_arg
    jsr     _LibErase14x14Sprite
:

    ; スプライトの描画
    lda     _ship + Ship::render_draw
    beq     :+
    lda     _ship + Ship::position_x
    sta     @draw_arg + $0000
    lda     _ship + Ship::position_y
    sta     @draw_arg + $0001
    lda     _ship + Ship::tileset_l
    sta     @draw_arg + $0002
    lda     _ship + Ship::tileset_h
    sta     @draw_arg + $0003
    ldx     #<@draw_arg
    lda     #>@draw_arg
    jsr     _LibDraw14x14Sprite
:

    ; 描画の更新
    lda     #$00
    sta     _ship + Ship::render_draw
    sta     _ship + Ship::render_erase

    ; 終了
    rts

; スプライト
@erase_arg:
@draw_arg:
    .byte   $00, $00
    .word   $0000

.endproc

; シップを操作する
;
.proc   ShipPlay

    ; 初期化
    lda     _ship + Ship::state
    bne     @initialized

    ; 生存の設定
    lda     #$00
    sta     _ship + Ship::alive

    ; 無敵の設定
    lda     #SHIP_NODAMAGE_SIZE
    sta     _ship + Ship::nodamage

    ; 位置の設定
    lda     #SHIP_X_START
    sta     _ship + Ship::position_x
    sta     _ship + Ship::last_x
    lda     #SHIP_Y_START
    sta     _ship + Ship::position_y
    sta     _ship + Ship::last_y

    ; 移動の設定
    lda     #$01
    sta     _ship + Ship::move_x

    ; タイルセットの設定
    lda     #<ship_tileset
    sta     _ship + Ship::tileset_l
    lda     #>ship_tileset
    sta     _ship + Ship::tileset_h

    ; 初期化の完了
    inc     _ship + Ship::state
@initialized:

    ; 位置の保存
    jsr     ShipStorePosition

    ; Y 位置の更新
    lda     _ship + Ship::position_y
    cmp     #SHIP_Y_PLAY
    beq     :+
    dec     _ship + Ship::position_y
    jmp     @play_end
:

    ; プレイの確認
    lda     _game + Game::play
    beq     @play_end

    ; 生存の設定
    lda     #$01
    sta     _ship + Ship::alive

    ; キー入力による移動
    lda     IOCS_0_KEYCODE
    cmp     #$08
    bne     :+
    lda     #$ff
    sta     _ship + Ship::move_x
    jmp     :++
:
    cmp     #$15
    bne     :+
    lda     #$01
    sta     _ship + Ship::move_x
:

    ; X 位置の更新
    lda     _ship + Ship::move_x
    clc
    adc     _ship + Ship::position_x
    sta     _ship + Ship::position_x
    bne     :+
    lda     #$01
    sta     _ship + Ship::move_x
    jmp     :++
:
    cmp     #FIELD_SIZE_X - $07
    bne     :+
    lda     #$ff
    sta     _ship + Ship::move_x
:

    ; ショットを撃つ
    lda     IOCS_0_KEYCODE
    cmp     #' '
    bne     :+
    lda     _ship + Ship::position_x
    clc
    adc     #$03
    jsr     _ShotShoot
:

    ; 操作の完了
@play_end:

    ; 無敵の更新
    lda     _ship + Ship::nodamage
    beq     :+
    dec     _ship + Ship::nodamage
:

    ; 描画の設定
    jsr     ShipSetRender

    ; 終了
    rts

.endproc

; シップが爆発する
;
.proc   ShipBomb

    ; 初期化
    lda     _ship + Ship::state
    bne     @initialized

    ; 生存の設定
    lda     #$00
    sta     _ship + Ship::alive

    ; アニメーションの設定
    lda     #$00
    sta     _ship + Ship::animation

    ; 初期化の完了
    inc     _ship + Ship::state
@initialized:

    ; 位置の保存
    jsr     ShipStorePosition

    ; タイルセットの設定
    ldy     _ship + Ship::animation
    lda     ship_tileset_bomb_l, y
    sta     _ship + Ship::tileset_l
    lda     ship_tileset_bomb_h, y
    sta     _ship + Ship::tileset_h
    
    ; アニメーションの更新
    inc     _ship + Ship::animation

    ; 描画の更新
    jsr     ShipSetRender

    ; 爆発の完了
    lda     _ship + Ship::animation
    cmp     #(BOMB_SIZE * $03)
    bcc     @end

    ; 描画の更新
    lda     #$00
    sta     _ship + Ship::render_draw
    lda     #$01
    sta     _ship + Ship::render_erase

    ; 処理の設定
    lda     #<ShipOut
    sta     _ship + Ship::function_l
    lda     #>ShipOut
    sta     _ship + Ship::function_h

    ; 状態の更新
    lda     #$00
    sta     _ship + Ship::state

    ; 終了
@end:
    rts

.endproc

; シップが外で待つ
;
.proc   ShipOut

;   ; 初期化
;   lda     _ship + Ship::state
;   bne     @initialized
;
;   ; 初期化の完了
;   inc     _ship + Ship::state
;@initialized:

    ; 状態の更新
    inc     _ship + Ship::state
    lda     _ship + Ship::state
    cmp     #$30
    bcc     @end

    ; 処理の設定
    lda     #<ShipPlay
    sta     _ship + Ship::function_l
    lda     #>ShipPlay
    sta     _ship + Ship::function_h

    ; 状態の設定
    lda     #$00
    sta     _ship + Ship::state

    ; 終了
@end:
    rts

.endproc

; シップが衝突判定を受けるかどうかを判定する
;
.global _ShipIsCollision
.proc   _ShipIsCollision

    ; OUT
    ;   a = !0..衝突判定を受ける

    ; コリジョンの判定
    lda     _ship + Ship::alive
    beq     :++
    lda     _ship + Ship::nodamage
    beq     :+
    lda     #$00
    jmp     :++
:    
    lda     #$01
:

    ; 終了
    rts

.endproc

; シップの位置を保存する
;
.proc   ShipStorePosition

    ; 位置の保存
    lda     _ship + Ship::position_x
    sta     _ship + Ship::last_x
    lda     _ship + Ship::position_y
    sta     _ship + Ship::last_y

    ; 終了
    rts

.endproc

; シップの X 位置を取得する
;
.global _ShipGetPositionX
.proc   _ShipGetPositionX

    ; OUT
    ;   a = X 位置

    ; X 位置の取得
    lda     _ship + Ship::position_x

    ; 終了
    rts

.endproc

; シップを爆発させる
;
.global _ShipSetBomb
.proc   _ShipSetBomb

    ; 生存の設定
    lda     #$00
    sta     _ship + Ship::alive

    ; 処理の設定
    lda     #<ShipBomb
    sta     _ship + Ship::function_l
    lda     #>ShipBomb
    sta     _ship + Ship::function_h

    ; 状態の設定
    lda     #$00
    sta     _ship + Ship::state

    ; 終了
    rts

.endproc

; シップの描画を設定する
;
.proc   ShipSetRender

    ; 描画の設定
;   lda     _ship + Ship::position_x
;   cmp     _ship + Ship::last_x
;   bne     :+
;   lda     _ship + Ship::position_y
;   cmp     _ship + Ship::last_y
;   beq     :++
;:
    lda     #$01
    sta     _ship + Ship::render_erase
;:
    lda     _ship + Ship::nodamage
    and     #%00000001
    bne     :+
    lda     #$01
    sta     _ship + Ship::render_draw
:

    ; 終了
    rts

.endproc

; タイルセット
;
ship_tileset:
    .incbin     "resources/sprites/ship.ptn"

; 爆発
ship_tileset_bomb_l:
    .byte   <_bomb_tileset_s_0
    .byte   <_bomb_tileset_s_0
    .byte   <_bomb_tileset_s_0
    .byte   <_bomb_tileset_s_1
    .byte   <_bomb_tileset_s_1
    .byte   <_bomb_tileset_s_1
    .byte   <_bomb_tileset_s_2
    .byte   <_bomb_tileset_s_2
    .byte   <_bomb_tileset_s_2
ship_tileset_bomb_h:
    .byte   >_bomb_tileset_s_0
    .byte   >_bomb_tileset_s_0
    .byte   >_bomb_tileset_s_0
    .byte   >_bomb_tileset_s_1
    .byte   >_bomb_tileset_s_1
    .byte   >_bomb_tileset_s_1
    .byte   >_bomb_tileset_s_2
    .byte   >_bomb_tileset_s_2
    .byte   >_bomb_tileset_s_2


; データの定義
;
.segment    "BSS"

; シップ
;
.global _ship
_ship:
    .tag    Ship

