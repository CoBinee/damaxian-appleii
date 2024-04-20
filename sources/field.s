; field.s - フィール尾
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


; コードの定義
;
.segment    "APP"

; フィールドをクリアする
;
.global _FieldClear
.proc   _FieldClear

    ; WORK
    ;   APP_0_WORK_0..2

    ; VRAM のクリア
    lda     #$00
    sta     APP_0_WORK_2
@clear:
    ldx     #$00
:
    lda     _iocs_hgr_tile_y_address_low, x
    sta     APP_0_WORK_0
    lda     _iocs_hgr_tile_y_address_high, x
    clc
    adc     APP_0_WORK_2
    sta     APP_0_WORK_1
    ldy     #$00
    lda     #$00
:
    sta     (APP_0_WORK_0), y
    iny
    cpy     #$20
    bne     :-
    inx
    cpx     #$18
    bne     :--
    lda     #$10
    jsr     _IocsWait
    lda     APP_0_WORK_2
    clc
    adc     #$04
    sta     APP_0_WORK_2
    cmp     #$20
    bne     @clear

    ; 終了
    rts

.endproc


; データの定義
;
.segment    "BSS"

