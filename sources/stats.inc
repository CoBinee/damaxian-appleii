; stats.inc - スタッツ
; 


; ゼロページ
;

; スコア
;
STATS_SCORE_SIZE                    =   $08

; レート
;
STATS_RATE_SIZE                     =   $04

; タイム
;
STATS_TIME_SIZE                     =   $04

; スタッツ
;
.struct Stats

    ; スコア
    score_10000000      .byte
    score_01000000      .byte
    score_00100000      .byte
    score_00010000      .byte
    score_00001000      .byte
    score_00000100      .byte
    score_00000010      .byte
    score_00000001      .byte
    score_draw          .byte

    ; ハイスコア
    hiscore_10000000    .byte
    hiscore_01000000    .byte
    hiscore_00100000    .byte
    hiscore_00010000    .byte
    hiscore_00001000    .byte
    hiscore_00000100    .byte
    hiscore_00000010    .byte
    hiscore_00000001    .byte
    hiscore_draw        .byte

    ; レート
    rate_1000           .byte
    rate_0100           .byte
    rate_0010           .byte
    rate_0001           .byte
    rate_draw           .byte

    ; タイム
    time_1000           .byte
    time_0100           .byte
    time_0010           .byte
    time_0001           .byte
    time_draw           .byte

.endstruct
