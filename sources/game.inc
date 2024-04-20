; game.inc - ゲーム
; 


; ゼロページ
;
GAME_0                              :=  APP_0_USER

; WORK
GAME_0_WORK_0                       :=  GAME_0 + $00
GAME_0_WORK_1                       :=  GAME_0 + $01
GAME_0_WORK_2                       :=  GAME_0 + $02
GAME_0_WORK_3                       :=  GAME_0 + $03

; SHIP
GAME_0_SHIP_0                       :=  GAME_0 + $04
GAME_0_SHIP_1                       :=  GAME_0 + $05
GAME_0_SHIP_2                       :=  GAME_0 + $06
GAME_0_SHIP_3                       :=  GAME_0 + $07

; ALIEN
GAME_0_ALIEN_0                      :=  GAME_0 + $04
GAME_0_ALIEN_1                      :=  GAME_0 + $05
GAME_0_ALIEN_2                      :=  GAME_0 + $06
GAME_0_ALIEN_3                      :=  GAME_0 + $07

; ヒット判定
GAME_0_HIT_SRC                      :=  GAME_0 + $04
GAME_0_HIT_DST                      :=  GAME_0 + $05
GAME_0_HIT_SRC_LEFT                 :=  GAME_0 + $06
GAME_0_HIT_SRC_TOP                  :=  GAME_0 + $07
GAME_0_HIT_SRC_RIGHT                :=  GAME_0 + $08
GAME_0_HIT_SRC_BOTTOM               :=  GAME_0 + $09
GAME_0_HIT_DST_LEFT                 :=  GAME_0 + $0a
GAME_0_HIT_DST_TOP                  :=  GAME_0 + $0b
GAME_0_HIT_DST_RIGHT                :=  GAME_0 + $0c
GAME_0_HIT_DST_BOTTOM               :=  GAME_0 + $0d

; レベル
;
GAME_LEVEL_SIZE                     =   $05

; ゲーム
;
.struct Game

    ; プレイ
    play                .byte

    ; レベル
    level               .byte

    ; スコア
    score_add           .byte

    ; ハイスコア
    hiscore_update      .byte

    ; レート

    ; タイム
    time_cycle          .byte

    ; カウント
    count               .byte

.endstruct
