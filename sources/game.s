; game.s - ゲーム
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
.include    "game.inc"
.include    "ship.inc"
.include    "alien.inc"
.include    "shot.inc"
.include    "bullet.inc"
.include    "star.inc"


; コードの定義
;
.segment    "APP"

; ゲームのエントリポイント
;
.global _GameEntry
.proc   _GameEntry

    ; アプリケーションの初期化

    ; ゲームの初期化
    jsr     GameInitialize

    ; シップの初期化
    jsr     _ShipInitialize

    ; エイリアンの初期化
    jsr     _AlienInitialize

    ; ショットの初期化
    jsr     _ShotInitialize

    ; 敵弾の初期化
    jsr     _BulletInitialize

    ; 星の初期化
    jsr     _StarInitialize

    ; 処理の設定
    lda     #<GameStart
    sta     APP_0_PROC_L
    lda     #>GameStart
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
    rts

.endproc

; ゲームを初期化する
;
.proc   GameInitialize

    ; 0 クリア
    ldx     #$00
    lda     #$00
:
    sta     _game, x
    inx
    cpx     #(.sizeof(Game))
    bne     :-

    ; フィールドのクリア
    jsr     _FieldClear

    ; 終了
    rts

.endproc

; ゲームを開始する
;
.proc   GameStart

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; プレイの停止
    lda     #$00
    sta     _game + Game::play

    ; スタッツの開始
    jsr     _StatsLoad

    ; タイムの設定
    lda     #$00
    sta     _game + Game::time_cycle

    ; カウントの設定
    lda     #$30
    sta     _game + Game::count

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; ゲームの更新
    jsr     GameUpdate

    ; カウントの更新
    dec     _game + Game::count
    beq     @next

    ; メッセージの描画
    ldx     #<@draw_arg
    lda     #>@draw_arg
    jsr     _IocsDrawString
    jmp     @end

    ; 次の処理へ
@next:

    ; メッセージの消去
    ldx     #<@erase_arg
    lda     #>@erase_arg
    jsr     _IocsDrawString

    ; 処理の設定
    lda     #<GamePlay
    sta     APP_0_PROC_L
    lda     #>GamePlay
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
@end:
    rts

; 描画
@draw_arg:
    .byte   14, 11
    .word   @draw_string
@draw_string:
    .byte   _HA, _ZI, _ME, '!', $00

; 消去
@erase_arg:
    .byte   11, 11
    .word   @erase_string
@erase_string:
    .asciiz "         "

.endproc

; ゲームをプレイする
;
.proc   GamePlay

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; プレイの開始
    lda     #$01
    sta     _game + Game::play

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; ヒット判定
    jsr     GameHit

    ; ゲームの更新
    jsr     GameUpdate

    ; プレイの完了
    lda     _game + Game::play
    bne     :+

    ; 処理の設定
    lda     #<GameOver
    sta     APP_0_PROC_L
    lda     #>GameOver
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE
:

    ; 終了
    rts

.endproc

; ゲームオーバーになる
;
.proc   GameOver

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; カウントの設定
    lda     #$60
    sta     _game + Game::count

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; ゲームの更新
    jsr     GameUpdate

    ; カウントとキー入力の監視
    dec     _game + Game::count
    beq     @next

    ; メッセージの描画
    ldx     #<@draw_arg
    lda     #>@draw_arg
    jsr     _IocsDrawString
    jmp     @end

    ; 次の処理へ
@next:

    ; メッセージの消去
    ldx     #<@erase_arg
    lda     #>@erase_arg
    jsr     _IocsDrawString

    ; 処理の設定
    lda     #<GameRecord
    sta     APP_0_PROC_L
    lda     #>GameRecord
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
@end:
    rts

; 描画
@draw_arg:
    .byte   14, 11
    .word   @draw_string
@draw_string:
    .byte   _SO, _KO, _MA, _DE, '!', $00

; 消去
@erase_arg:
    .byte   14, 11
    .word   @erase_string
@erase_string:
    .asciiz "     "

.endproc

; ハイスコアを更新する
;
.proc   GameRecord

    ; 初期化
    lda     APP_0_STATE
    bne     @initialized

    ; スコアの設定
    ldx     #$00
:
    lda     _stats + Stats::score_10000000, x
    bne     :+
    lda     #' '
    sta     @draw_score_number_string, x
    inx
    cpx     #STATS_SCORE_SIZE - $01
    bne     :-
:
    lda     _stats + Stats::score_10000000, x
    clc
    adc     #'0'
    sta     @draw_score_number_string, x
    inx
    cpx     #STATS_SCORE_SIZE
    bne     :-

    ; カウントの設定
    lda     #$30
    sta     _game + Game::count

    ; 初期化の完了
    inc     APP_0_STATE
@initialized:

    ; ゲームの更新
    jsr     GameUpdate

    ; カウントとキー入力の監視
    lda     _game + Game::count
    bne     :+
    lda     IOCS_0_KEYCODE
    bne     @next
    jmp     :++
:
    dec     _game + Game::count
:

    ; スコアの描画
    ldx     #<@draw_score_arg
    lda     #>@draw_score_arg
    jsr     _IocsDrawString

    ; ハイスコアの描画
    lda     _game + Game::hiscore_update
    beq     :+
    ldx     #<@draw_hiscore_arg
    lda     #>@draw_hiscore_arg
    jsr     _IocsDrawString
:
    jmp     @end

    ; 次の処理へ
@next:

    ; スコアの消去
    ldx     #<@erase_score_arg
    lda     #>@erase_score_arg
    jsr     _IocsDrawString

    ; ハイスコアの消去
    lda     _game + Game::hiscore_update
    beq     :+
    ldx     #<@erase_hiscore_arg
    lda     #>@erase_hiscore_arg
    jsr     _IocsDrawString
:

    ; 処理の設定
    lda     #<GameEnd
    sta     APP_0_PROC_L
    lda     #>GameEnd
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
@end:
    rts

; スコア
@draw_score_arg:
    .byte   9, 11
    .word   @draw_score_string
@draw_score_string:
    .byte   _TO, _KU, _TE, __N, ' ', '-', ' '
@draw_score_number_string:
    .byte   '0', '1', '2', '3', '4', '5', '6', '7', ' ', $00
@erase_score_arg:
    .byte   9, 11
    .word   @erase_score_string
@erase_score_string:
    .asciiz "               "

; ハイスコア
@draw_hiscore_arg:
    .byte   12, 14
    .word   @draw_hiscore_string
@draw_hiscore_string:
    .byte   _KI, _RO, _KU, ' ', _KO, __U, _SI, __N, '!', $00
@erase_hiscore_arg:
    .byte   12, 14
    .word   @erase_hiscore_string
@erase_hiscore_string:
    .asciiz "         "

.endproc

; ゲームを終了する
;
.proc   GameEnd

    ; 処理の設定
    lda     #<_TitleEntry
    sta     APP_0_PROC_L
    lda     #>_TitleEntry
    sta     APP_0_PROC_H

    ; 状態の設定
    lda     #$00
    sta     APP_0_STATE

    ; 終了
    rts

.endproc

; ゲームを更新する
;
.proc GameUpdate

    ; スタッツの更新
    jsr     GameUpdateStats

    ; シップの更新
    jsr     _ShipUpdate

    ; エイリアンの更新
    jsr     _AlienUpdate

    ; ショットの更新
    jsr     _ShotUpdate

    ; 敵弾の更新
    jsr     _BulletUpdate

    ; 星の更新
    jsr     _StarUpdate

    ; 星の描画
    jsr     _StarRender

    ; ショットの描画
    jsr     _ShotRender

    ; 敵弾の描画
    jsr     _BulletRender

    ; エイリアンの描画
    jsr     _AlienRender

    ; シップの描画
    jsr     _ShipRender

    ; スタッツの描画
    jsr     _StatsRender

    ; ショットの後始末
    jsr     _ShotCleanup

    ; 終了
    rts

.endproc

; ヒット判定を行う
;
.proc   GameHit

    ; シップの位置の取得
    lda     _ship + Ship::position_x
    clc
    adc     #$02
    sta     GAME_0_HIT_DST_LEFT
;   clc
    adc     #$03
    sta     GAME_0_HIT_DST_RIGHT
    lda     _ship + Ship::position_y
    clc
    adc     #$02
    sta     GAME_0_HIT_DST_TOP
;   clc
    adc     #$03
    sta     GAME_0_HIT_DST_BOTTOM

    ; エイリアンの判定
    lda     #$00
    sta     GAME_0_HIT_SRC
@alien:

    ; エイリアンの存在
    ldx     GAME_0_HIT_SRC
    jsr     _AlienIsActive
    and     #$ff
    bne     :+
    jmp     @alien_next
:

    ; エイリアンの位置の取得
    lda     _alien_position_x, x
    tay
    bpl     :+
    lda     #$00
:
    sta     GAME_0_HIT_SRC_LEFT
    tya
    clc
    adc     #$07
    cmp     #$70
    bcc     :+
    lda     #$70
:
    sta     GAME_0_HIT_SRC_RIGHT
    lda     _alien_position_y, x
    tay
    bpl     :+
    lda     #$00
:
    sta     GAME_0_HIT_SRC_TOP
    tya
    clc
    adc     #$07
    cmp     #$60
    bcc     :+
    lda     #$60
:
    sta     GAME_0_HIT_SRC_BOTTOM

    ; ショットとの判定
    lda     #$00
    sta     GAME_0_HIT_DST
@alien_shot:

    ; ショットの存在
    ldy     GAME_0_HIT_DST
    lda     _shot_state, y
    beq     @alien_shot_next

    ; Y 位置の比較
    lda     _shot_position_y, y
    bmi     @alien_shot_next
    cmp     GAME_0_HIT_SRC_TOP
    bcc     @alien_shot_next
    cmp     GAME_0_HIT_SRC_BOTTOM
    bcs     @alien_shot_next

    ; X 位置の比較
    lda     _shot_position_x, y
    cmp     GAME_0_HIT_SRC_LEFT
    bcc     @alien_shot_next
    cmp     GAME_0_HIT_SRC_RIGHT
    bcs     @alien_shot_next

    ; エイリアンにヒット
    jsr     _AlienSetBomb

    ; スコアの加算
    ldx     GAME_0_HIT_SRC
    lda     _alien_score, x
    clc
    adc     _game + Game::score_add
    sta     _game + Game::score_add

    ; ショットの削除
    ldx     GAME_0_HIT_DST
    jsr     _ShotKill

    ; 次のショットへ
@alien_shot_next:
    inc     GAME_0_HIT_DST
    lda     GAME_0_HIT_DST
    cmp     #SHOT_ENTRY
    bne     @alien_shot

    ; シップとの判定
    jsr     _ShipIsCollision
    and     #$ff
    beq     @alien_ship_end

    ; Y 位置のの比較
    lda     GAME_0_HIT_DST_TOP
    cmp     GAME_0_HIT_SRC_BOTTOM
    bcs     @alien_ship_end
    lda     GAME_0_HIT_DST_BOTTOM
    cmp     GAME_0_HIT_SRC_TOP
    bcc     @alien_ship_end
    
    ; X 位置のの比較
    lda     GAME_0_HIT_DST_LEFT
    cmp     GAME_0_HIT_SRC_RIGHT
    bcs     @alien_ship_end
    lda     GAME_0_HIT_DST_RIGHT
    cmp     GAME_0_HIT_SRC_LEFT
    bcc     @alien_ship_end

    ; シップにヒット
    jsr     _ShipSetBomb
    
    ; シップとの判定の完了
@alien_ship_end:

    ; 次のエイリアンへ
@alien_next:
    inc     GAME_0_HIT_SRC
    lda     GAME_0_HIT_SRC
    cmp     #ALIEN_ENTRY
    beq     :+
    jmp     @alien
:

    ; シップの現存
    jsr     _ShipIsCollision
    and     #$ff
    beq     @bullet_end

    ; 敵弾の判定
    lda     #$00
    sta     GAME_0_HIT_SRC
@bullet:

    ; 敵弾の存在
    ldx     GAME_0_HIT_SRC
    lda     _bullet_state, x
    beq     @bullet_next

    ; 敵弾の位置の取得
    lda     _bullet_position_x, x
    tay
    bpl     :+
    lda     #$00
:
    sta     GAME_0_HIT_SRC_LEFT
    tya
    clc
    adc     #$04
    cmp     #$70
    bcc     :+
    lda     #$70
:
    sta     GAME_0_HIT_SRC_RIGHT
    lda     _bullet_position_y, x
    tay
    bpl     :+
    lda     #$00
:
    sta     GAME_0_HIT_SRC_TOP
    tya
    clc
    adc     #$04
    cmp     #$60
    bcc     :+
    lda     #$60
:
    sta     GAME_0_HIT_SRC_BOTTOM

    ; Y 位置のの比較
    lda     GAME_0_HIT_DST_TOP
    cmp     GAME_0_HIT_SRC_BOTTOM
    bcs     @bullet_next
    lda     GAME_0_HIT_DST_BOTTOM
    cmp     GAME_0_HIT_SRC_TOP
    bcc     @bullet_next
    
    ; X 位置のの比較
    lda     GAME_0_HIT_DST_LEFT
    cmp     GAME_0_HIT_SRC_RIGHT
    bcs     @bullet_next
    lda     GAME_0_HIT_DST_RIGHT
    cmp     GAME_0_HIT_SRC_LEFT
    bcc     @bullet_next

    ; シップにヒット
    jsr     _ShipSetBomb
    jmp     @bullet_end
    
    ; 次の敵弾へ
@bullet_next:
    inc     GAME_0_HIT_SRC
    lda     GAME_0_HIT_SRC
    cmp     #BULLET_ENTRY
    bne     @bullet
@bullet_end:

    ; 終了
    rts

.endproc

; スタッツを更新する
;
.proc   GameUpdateStats

    ; WORK
    ;   GAME_0_WORK_0

    ; スコアの更新
    ldx     _game + Game::score_add
    bne     @score_add
    jmp     @score_end
@score_add:
    clc
    lda     _stats + Stats::rate_0001
    adc     _stats + Stats::score_00000001
    sta     _stats + Stats::score_00000001
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00000001
:
    lda     _stats + Stats::rate_0010
    adc     _stats + Stats::score_00000010
    sta     _stats + Stats::score_00000010
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00000010
:
    lda     _stats + Stats::rate_0100
    adc     _stats + Stats::score_00000100
    sta     _stats + Stats::score_00000100
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00000100
:
    lda     _stats + Stats::rate_1000
    adc     _stats + Stats::score_00001000
    sta     _stats + Stats::score_00001000
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00001000
    inc     _stats + Stats::score_00010000
    lda     _stats + Stats::score_00010000
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00010000
    inc     _stats + Stats::score_00100000
    lda     _stats + Stats::score_00100000
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_00100000
    inc     _stats + Stats::score_01000000
    lda     _stats + Stats::score_01000000
    sec
    sbc     #$0a
    bcc     :+
    sta     _stats + Stats::score_01000000
    inc     _stats + Stats::score_10000000
    lda     _stats + Stats::score_10000000
    sec
    sbc     #$0a
    bcc     :+
    lda     #$09
    sta     _stats + Stats::score_10000000
    sta     _stats + Stats::score_01000000
    sta     _stats + Stats::score_00100000
    sta     _stats + Stats::score_00010000
    sta     _stats + Stats::score_00001000
    sta     _stats + Stats::score_00000100
    sta     _stats + Stats::score_00000010
    sta     _stats + Stats::score_00000001
:
    dex
    beq     :+
    jmp     @score_add
:
    lda     #$01
    sta     _stats + Stats::score_draw
@score_end:

    ; ハイスコアの更新
    lda     _game + Game::score_add
    beq     @hiscore_end
    lda     _game + Game::hiscore_update
    bne     @hiscore_update
    ldx     #$00
:
    lda     _stats + Stats::score_10000000, x
    cmp     _stats + Stats::hiscore_10000000, x
    bne     :+
    inx
    cpx     #STATS_SCORE_SIZE
    bne     :-
:
    bcc     @hiscore_end
    lda     #$01
    sta     _game + Game::hiscore_update
@hiscore_update:
    ldx     #$00
:
    lda     _stats + Stats::score_10000000, x
    sta     _stats + Stats::hiscore_10000000, x
    inx
    cpx     #STATS_SCORE_SIZE
    bne     :-
    lda     #$01
    sta     _stats + Stats::hiscore_draw
@hiscore_end:

    ; レートの更新
    lda     _game + Game::score_add
    beq     @rate_down
@rate_up:
    lda     _stats + Stats::rate_1000
    bne     @rate_end
    clc
    lda     #$02
    adc     _stats + Stats::rate_0010
    sta     _stats + Stats::rate_0010
    sec
    sbc     #$0a
    bcc     @rate_draw
    sta     _stats + Stats::rate_0010
    inc     _stats + Stats::rate_0100
    lda     _stats + Stats::rate_0100
    sec
    sbc     #$0a
    bcc     :+
    lda     #$01
    sta     _stats + Stats::rate_1000
    lda     #$00
    sta     _stats + Stats::rate_0100
    sta     _stats + Stats::rate_0010
    sta     _stats + Stats::rate_0001
:
    jmp     @rate_draw
@rate_down:
    lda     _stats + Stats::rate_1000
    bne     :+
    lda     _stats + Stats::rate_0100
    bne     :+
    lda     _stats + Stats::rate_0001
    bne     :+
    lda     _stats + Stats::rate_0010
    cmp     #$01
    beq     @rate_clear
:
    dec     _stats + Stats::rate_0001
    bpl     @rate_draw
    lda     #$09
    sta     _stats + Stats::rate_0001
    dec     _stats + Stats::rate_0010
    bpl     :+
    lda     #$09
    sta     _stats + Stats::rate_0010
    dec     _stats + Stats::rate_0100
    bpl     :+
    lda     #$09
    sta     _stats + Stats::rate_0100
    dec     _stats + Stats::rate_1000
:
;   jmp     @rate_draw
@rate_draw:
    lda     #$01
    sta     _stats + Stats::rate_draw
@rate_clear:
    lda     #$00
    sta     _game + Game::score_add
@rate_end:

    ; タイムの更新
    lda     _game + Game::play
    beq     @time_end
    inc     _game + Game::time_cycle
    lda     _game + Game::time_cycle
    and     #%00000001
    bne     @time_end
    dec     _stats + Stats::time_0001
    bpl     :+
    lda     #$09
    sta     _stats + Stats::time_0001
    dec     _stats + Stats::time_0010
    bpl     :+
    lda     #$09
    sta     _stats + Stats::time_0010
    dec     _stats + Stats::time_0100
    bpl     :+
    lda     #$09
    sta     _stats + Stats::time_0100
    dec     _stats + Stats::time_1000
    bpl     :+
    lda     #$00
    sta     _stats + Stats::time_1000
    sta     _stats + Stats::time_0100
    sta     _stats + Stats::time_0010
    sta     _stats + Stats::time_0001
    sta     _game + Game::play
    jmp     @time_end
:
;   jmp     @time_draw
@time_draw:
    lda     #$01
    sta     _stats + Stats::time_draw
@time_end:

    ; レベルの更新
    ldx     #$00
    lda     _stats + Stats::time_1000
    beq     :+
    lda     #$00
    jmp     :++
:
    lda     #$09
    sec
    sbc     _stats + Stats::time_0100
    lsr     a
:
    sta     _game + Game::level

    ; 終了
    rts

.endproc


; データの定義
;
.segment    "BSS"

; ゲーム
;
.global _game
_game:
    .tag    Game

