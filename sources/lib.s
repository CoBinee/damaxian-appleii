; lib.s - ライブラリ
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


; コードの定義
;
.segment    "BOOT"

; 14x14 サイズのスプライトを描画する
;
.global _LibDraw14x14Sprite
.proc   _LibDraw14x14Sprite

    ; IN
    ;   ax[0]    = X 位置
    ;   ax[1]    = Y 位置
    ;   ax[2..3] = タイルセット

    ; 引数の保持
    stx     LIB_0_SPRITE_ARG_L
    sta     LIB_0_SPRITE_ARG_H

    ; X 位置の取得
    ldy     #$00
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$06
    cmp     #($06 + $70)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tax
    lda     lib_14x14_sprite_x_tile, x
    sta     LIB_0_SPRITE_X

    ; 幅の取得
    lda     lib_14x14_sprite_width, x
    sta     LIB_0_SPRITE_WIDTH

    ; Y 位置と高さの取得
;   ldy     #$01
    iny
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$06
    cmp     #($06 + $60)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tay
    lda     lib_14x14_sprite_y_line, y
    sta     LIB_0_SPRITE_Y
    lda     lib_14x14_sprite_height, y
    sta     LIB_0_SPRITE_HEIGHT
    lda     lib_14x14_sprite_tileset_start_low, y
    clc
    adc     lib_14x14_sprite_tileset_offset_low, x
    sta     LIB_0_SPRITE_SRC_L
    lda     #$00
    sta     LIB_0_SPRITE_SRC_H

    ; タイルセットの取得
    ldy     #$02
    lda     LIB_0_SPRITE_SRC_L
    clc
    adc     (LIB_0_SPRITE_ARG), y
    sta     LIB_0_SPRITE_SRC_L
    iny
    lda     LIB_0_SPRITE_SRC_H
    adc     (LIB_0_SPRITE_ARG), y
    sta     LIB_0_SPRITE_SRC_H

    ; VRAM アドレスの取得
    lda     LIB_0_SPRITE_Y
    pha
    lsr     a
    lsr     a
    sta     LIB_0_SPRITE_Y
    tay
    lda     _iocs_hgr_tile_y_address_low, y
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, y
    sta     LIB_0_SPRITE_DST_H
    pla
    and     #$03
    asl     a
    asl     a
    asl     a
    clc
    adc     LIB_0_SPRITE_DST_H
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L

    ; 幅別の描画
    dec     LIB_0_SPRITE_WIDTH
    beq     @draw1
    dec     LIB_0_SPRITE_WIDTH
    beq     @draw2
    jmp     @draw3

    ; 横 1 タイルの描画
@draw1:
    ldy     #$00
:
    ldx     #$00
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    iny
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcc     :--
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :--

    ; 横 2 タイルの描画
@draw2:
    ldy     #$00
:
    ldx     #$00
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 横 3 タイルの描画
@draw3:
    ldy     #$00
:
    ldx     #$00
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    dec     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 描画の完了    
@draw_end:

    ; 終了
    rts

.endproc

; 14x14 サイズのスプライトを消去する
;
.global _LibErase14x14Sprite
.proc   _LibErase14x14Sprite

    ; IN
    ;   ax[0]    = X 位置
    ;   ax[1]    = Y 位置

    ; 引数の保持
    stx     LIB_0_SPRITE_ARG_L
    sta     LIB_0_SPRITE_ARG_H

    ; X 位置の取得
    ldy     #$00
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$06
    cmp     #($06 + $70)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tax
    lda     lib_14x14_sprite_x_tile, x
    sta     LIB_0_SPRITE_X

    ; 幅の取得
    lda     lib_14x14_sprite_width, x
    sta     LIB_0_SPRITE_WIDTH

    ; Y 位置と高さの取得
;   ldy     #$01
    iny
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$06
    cmp     #($06 + $60)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tay
    lda     lib_14x14_sprite_y_line, y
    sta     LIB_0_SPRITE_Y
    lda     lib_14x14_sprite_height, y
    sta     LIB_0_SPRITE_HEIGHT

    ; VRAM アドレスの取得
    lda     LIB_0_SPRITE_Y
    pha
    lsr     a
    lsr     a
    sta     LIB_0_SPRITE_Y
    tay
    lda     _iocs_hgr_tile_y_address_low, y
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, y
    sta     LIB_0_SPRITE_DST_H
    pla
    and     #$03
    asl     a
    asl     a
    asl     a
    clc
    adc     LIB_0_SPRITE_DST_H
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L

    ; 幅別の消去
    dec     LIB_0_SPRITE_WIDTH
    beq     @erase1
    dec     LIB_0_SPRITE_WIDTH
    beq     @erase2
    jmp     @erase3

    ; 横 1 タイルの消去
@erase1:
    ldy     LIB_0_SPRITE_HEIGHT
:
    ldx     #$00
    txa
    sta     (LIB_0_SPRITE_DST, x)
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    txa
    sta     (LIB_0_SPRITE_DST, x)
    dey
    bne     :+
;   jmp     @erase_end
    rts
:
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcc     :--
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :--

    ; 横 2 タイルの消去
@erase2:
    ldy     LIB_0_SPRITE_HEIGHT
:
    ldx     #$00
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    dey
    bne     :+
;   jmp     @erase_end
    rts
:
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 横 3 タイルの消去
@erase3:
    ldy     LIB_0_SPRITE_HEIGHT
:
    ldx     #$00
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST, x)
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    dec     LIB_0_SPRITE_DST_L
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST, x)
    dey
    bne     :+
;   jmp     @erase_end
    rts
:
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 描画の完了    
@erase_end:

    ; 終了
    rts

.endproc

; 8x8 サイズのスプライトを描画する
;
.global _LibDraw8x8Sprite
.proc   _LibDraw8x8Sprite

    ; IN
    ;   ax[0]    = X 位置
    ;   ax[1]    = Y 位置
    ;   ax[2..3] = タイルセット

    ; 引数の保持
    stx     LIB_0_SPRITE_ARG_L
    sta     LIB_0_SPRITE_ARG_H

    ; X 位置の取得
    ldy     #$00
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$03
    cmp     #($03 + $70)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tax
    lda     lib_8x8_sprite_x_tile, x
    sta     LIB_0_SPRITE_X

    ; 幅の取得
    lda     lib_8x8_sprite_width, x
    sta     LIB_0_SPRITE_WIDTH

    ; Y 位置と高さの取得
;   ldy     #$01
    iny
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$03
    cmp     #($03 + $60)
    bcc     :+
;   jmp     @draw_end
    rts
:
    tay
    lda     lib_8x8_sprite_y_line, y
    sta     LIB_0_SPRITE_Y
    lda     lib_8x8_sprite_height, y
    sta     LIB_0_SPRITE_HEIGHT
    lda     lib_8x8_sprite_tileset_start_low, y
    clc
    adc     lib_8x8_sprite_tileset_offset_low, x
    sta     LIB_0_SPRITE_SRC_L
    lda     #$00
    sta     LIB_0_SPRITE_SRC_H

    ; タイルセットの取得
    ldy     #$02
    lda     LIB_0_SPRITE_SRC_L
    clc
    adc     (LIB_0_SPRITE_ARG), y
    sta     LIB_0_SPRITE_SRC_L
    iny
    lda     LIB_0_SPRITE_SRC_H
    adc     (LIB_0_SPRITE_ARG), y
    sta     LIB_0_SPRITE_SRC_H

    ; VRAM アドレスの取得
    lda     LIB_0_SPRITE_Y
    pha
    lsr     a
    lsr     a
    sta     LIB_0_SPRITE_Y
    tay
    lda     _iocs_hgr_tile_y_address_low, y
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, y
    sta     LIB_0_SPRITE_DST_H
    pla
    and     #$03
    asl     a
    asl     a
    asl     a
    clc
    adc     LIB_0_SPRITE_DST_H
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L

    ; 幅別の描画
    dec     LIB_0_SPRITE_WIDTH
    bne     @draw2

    ; 横 1 タイルの描画
@draw1:
    ldy     #$00
:
    ldx     #$00
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    iny
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcc     :--
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :--

    ; 横 2 タイルの描画
@draw2:
    ldy     #$00
:
    ldx     #$00
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST, x)
    iny
    inc     LIB_0_SPRITE_DST_L
    lda     (LIB_0_SPRITE_SRC), y
    sta     (LIB_0_SPRITE_DST ,x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    iny
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 描画の完了    
@draw_end:

    ; 終了
    rts

.endproc

; 8x8 サイズのスプライトを消去する
;
.global _LibErase8x8Sprite
.proc   _LibErase8x8Sprite

    ; IN
    ;   ax[0]    = X 位置
    ;   ax[1]    = Y 位置

    ; 引数の保持
    stx     LIB_0_SPRITE_ARG_L
    sta     LIB_0_SPRITE_ARG_H

    ; X 位置の取得
    ldy     #$00
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$03
    cmp     #($03 + $70)
    bcc     :+
;   jmp     @erase_end
    rts
:
    tax
    lda     lib_8x8_sprite_x_tile, x
    sta     LIB_0_SPRITE_X

    ; 幅の取得
    lda     lib_8x8_sprite_width, x
    sta     LIB_0_SPRITE_WIDTH

    ; Y 位置と高さの取得
;   ldy     #$01
    iny
    lda     (LIB_0_SPRITE_ARG), y
    clc
    adc     #$03
    cmp     #($03 + $60)
    bcc     :+
;   jmp     @erase_end
    rts
:
    tay
    lda     lib_8x8_sprite_y_line, y
    sta     LIB_0_SPRITE_Y
    lda     lib_8x8_sprite_height, y
    sta     LIB_0_SPRITE_HEIGHT

    ; VRAM アドレスの取得
    lda     LIB_0_SPRITE_Y
    pha
    lsr     a
    lsr     a
    sta     LIB_0_SPRITE_Y
    tay
    lda     _iocs_hgr_tile_y_address_low, y
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, y
    sta     LIB_0_SPRITE_DST_H
    pla
    and     #$03
    asl     a
    asl     a
    asl     a
    clc
    adc     LIB_0_SPRITE_DST_H
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L

    ; 幅別の描画
    dec     LIB_0_SPRITE_WIDTH
    bne     @erase2

    ; 横 1 タイルの消去
@erase1:
:
    ldx     #$00
    txa
    sta     (LIB_0_SPRITE_DST, x)
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    txa
    sta     (LIB_0_SPRITE_DST, x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @draw_end
    rts
:
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcc     :--
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :--

    ; 横 2 タイルの消去
@erase2:
:
    ldx     #$00
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    sta     LIB_0_SPRITE_DST_H
    dec     LIB_0_SPRITE_DST_L
    txa
    sta     (LIB_0_SPRITE_DST, x)
    inc     LIB_0_SPRITE_DST_L
    sta     (LIB_0_SPRITE_DST ,x)
    dec     LIB_0_SPRITE_HEIGHT
    bne     :+
;   jmp     @erase_end
    rts
:
    lda     LIB_0_SPRITE_DST_H
    clc
    adc     #$04
    cmp     #$40
    sta     LIB_0_SPRITE_DST_H
    bcs     :+
    dec     LIB_0_SPRITE_DST_L
    jmp     :--
:
    inc     LIB_0_SPRITE_Y
    ldx     LIB_0_SPRITE_Y
    lda     _iocs_hgr_tile_y_address_low, x
    sta     LIB_0_SPRITE_DST_L
    lda     _iocs_hgr_tile_y_address_high, x
    sta     LIB_0_SPRITE_DST_H
    lda     LIB_0_SPRITE_X
    clc
    adc     LIB_0_SPRITE_DST_L
    sta     LIB_0_SPRITE_DST_L
    jmp     :---

    ; 消去の完了    
@erase_end:

    ; 終了
    rts

.endproc

; タイルセット単位の処理待ちを行う
;
.global _LibWaitTileset
.proc   _LibWaitTileset

    ; IN
    ;   a = タイルセット数
    ; WORK
    ;   LIB_0_WORK_0..1

    ; レジスタの保存
    stx     LIB_0_WORK_0
    sty     LIB_0_WORK_1

    ; タイルセットを描画する単位で処理待ちを行う
    sta     LIB_0_WAIT_SIZE
:
    lda     #<:-
    sta     LIB_0_WAIT_SRC_L
    lda     #>:-
    sta     LIB_0_WAIT_SRC_H
    lda     #<$2078
    sta     LIB_0_WAIT_DST_L
    lda     #>$2078
    sta     LIB_0_WAIT_DST_H
    lda     #$08
    sta     LIB_0_WAIT_HEIGHT
    ldy     #$00
    ldx     #$00
:
    lda     (LIB_0_WAIT_SRC), y
    sta     (LIB_0_WAIT_DST, x)
    iny
    lda     LIB_0_WAIT_DST_H
    clc
    adc     #$04
    sta     LIB_0_WAIT_DST_H
    dec     LIB_0_WAIT_HEIGHT
    bne     :-
    dec     LIB_0_WAIT_SIZE
    bne     :--

    ; レジスタの復帰
    ldy     LIB_0_WORK_1
    ldx     LIB_0_WORK_0

    ; 終了
    rts

.endproc

; スプライト
;

; X 位置
lib_14x14_sprite_x_tile:
    .byte        $00, $00, $00
lib_8x8_sprite_x_tile:
    .byte                       $00, $00, $00
lib_14x14_8x8_sprite_x_tile_0:
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
lib_14x14_sprite_x_pixel:
    .byte        $01, $02, $03
lib_8x8_sprite_x_pixel:
    .byte                       $04, $05, $06
lib_14x14_8x8_sprite_x_pixel_0:
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06
    .byte   $00, $01, $02, $03, $04, $05, $06

; Y 位置
lib_14x14_sprite_y_line:
    .byte             $00, $00, $00
lib_8x8_sprite_y_line:
    .byte                            $00, $00, $00
lib_14x14_8x8_sprite_y_line_0:
    .byte   $00, $01, $02, $03, $04, $05, $06, $07
    .byte   $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
    .byte   $10, $11, $12, $13, $14, $15, $16, $17
    .byte   $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
    .byte   $20, $21, $22, $23, $24, $25, $26, $27
    .byte   $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
    .byte   $30, $31, $32, $33, $34, $35, $36, $37
    .byte   $38, $39, $3a, $3b, $3c, $3d, $3e, $3f
    .byte   $40, $41, $42, $43, $44, $45, $46, $47
    .byte   $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
    .byte   $50, $51, $52, $53, $54, $55, $56, $57
    .byte   $58, $59, $5a, $5b, $5c, $5d, $5e, $5f

; 幅
lib_14x14_sprite_width:
    .byte        $01, $01, $01, $02, $02, $02
lib_14x14_sprite_width_0:
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $03, $03, $03, $03, $03, $03
    .byte   $02, $02, $02, $02, $01, $01, $01
lib_8x8_sprite_width:
    .byte                       $01, $01, $01
lib_8x8_sprite_width_0:
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $02, $02, $02
    .byte   $02, $02, $02, $02, $01, $01, $01

; 高さ
lib_14x14_sprite_height:
    .byte             $01, $02, $03, $04, $05, $06
lib_14x14_sprite_height_0:
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $07, $07, $07, $07, $07, $07
    .byte   $07, $07, $06, $05, $04, $03, $02, $01
lib_8x8_sprite_height:
    .byte                            $01, $02, $03
lib_8x8_sprite_height_0:
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $04, $04, $04
    .byte   $04, $04, $04, $04, $04, $03, $02, $01

; タイルセット
lib_14x14_sprite_tileset_start_low:
    .byte        $2a, $24, $1e, $18, $12, $0c, $06
lib_14x14_sprite_tileset_start_low_0:
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
lib_14x14_sprite_tileset_offset_low:
    .byte        $2c, $56, $80, $a9, $d3, $fd
lib_14x14_sprite_tileset_offset_low_0:
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
    .byte   $00, $2a, $54, $7e, $a8, $d2, $fc
lib_8x8_sprite_tileset_start_low:
    .byte                            $0c, $08, $04
lib_8x8_sprite_tileset_start_low_0:
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
    .byte   $00, $00, $00, $00, $00, $00, $00, $00
lib_8x8_sprite_tileset_offset_low:
    .byte                       $41, $51, $61
lib_8x8_sprite_tileset_offset_low_0:
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60
    .byte   $00, $10, $20, $30, $40, $50, $60


; データの定義
;
.segment    "BSS"

