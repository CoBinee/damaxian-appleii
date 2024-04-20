; lib.inc - ライブラリ
; 


; ゼロページ
;
LIB_0                               :=  $10

; WORK
LIB_0_WORK_0                        :=  IOCS_0_WORK_0
LIB_0_WORK_1                        :=  IOCS_0_WORK_1
LIB_0_WORK_2                        :=  IOCS_0_WORK_2
LIB_0_WORK_3                        :=  IOCS_0_WORK_3

; SPRITE
LIB_0_SPRITE_ARG                    :=  LIB_0 + $00
LIB_0_SPRITE_ARG_L                  :=  LIB_0 + $00
LIB_0_SPRITE_ARG_H                  :=  LIB_0 + $01
LIB_0_SPRITE_SRC                    :=  LIB_0 + $02
LIB_0_SPRITE_SRC_L                  :=  LIB_0 + $02
LIB_0_SPRITE_SRC_H                  :=  LIB_0 + $03
LIB_0_SPRITE_DST                    :=  LIB_0 + $04
LIB_0_SPRITE_DST_L                  :=  LIB_0 + $04
LIB_0_SPRITE_DST_H                  :=  LIB_0 + $05
LIB_0_SPRITE_X                      :=  LIB_0 + $06
LIB_0_SPRITE_Y                      :=  LIB_0 + $07
LIB_0_SPRITE_WIDTH                  :=  LIB_0 + $08
LIB_0_SPRITE_HEIGHT                 :=  LIB_0 + $09

; WAIT
LIB_0_WAIT_SIZE                     :=  LIB_0 + $00
LIB_0_WAIT_SRC                      :=  LIB_0 + $01
LIB_0_WAIT_SRC_L                    :=  LIB_0 + $01
LIB_0_WAIT_SRC_H                    :=  LIB_0 + $02
LIB_0_WAIT_DST                      :=  LIB_0 + $03
LIB_0_WAIT_DST_L                    :=  LIB_0 + $03
LIB_0_WAIT_DST_H                    :=  LIB_0 + $04
LIB_0_WAIT_HEIGHT                   :=  LIB_0 + $05
