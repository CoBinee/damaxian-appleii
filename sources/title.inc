; title.inc - タイトル
; 


; ゼロページ
;
TITLE_0                             :=  APP_0_USER

; WORK
TITLE_0_WORK_0                      :=  TITLE_0 + $00
TITLE_0_WORK_1                      :=  TITLE_0 + $01
TITLE_0_WORK_2                      :=  TITLE_0 + $02
TITLE_0_WORK_3                      :=  TITLE_0 + $03

; 明滅
TITLE_0_FLICK_INDEX                 :=  TITLE_0 + $04
TITLE_0_FLICK_VRAM                  :=  TITLE_0 + $05
TITLE_0_FLICK_VRAM_L                :=  TITLE_0 + $05
TITLE_0_FLICK_VRAM_H                :=  TITLE_0 + $06
TITLE_0_FLICK_X                     :=  TITLE_0 + $07
TITLE_0_FLICK_Y                     :=  TITLE_0 + $08
TITLE_0_FLICK_WIDTH                 :=  TITLE_0 + $09
TITLE_0_FLICK_HEIGHT                :=  TITLE_0 + $0a

; タイトル
;
.struct Title

    ; カウント
    count               .byte

    ; 点滅
    blink               .byte

    ; 明滅
    flick_count         .byte
    flick_draw          .byte
    flick_erase         .byte

.endstruct
