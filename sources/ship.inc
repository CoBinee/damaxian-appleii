; ship.inc - シップ
; 


; ゼロページ
;

; 無敵
;
SHIP_NODAMAGE_SIZE                  =   $20

; 位置
;
SHIP_X_START                        =   $34
SHIP_Y_START                        =   $60
SHIP_Y_PLAY                         =   $54

; シップ
;
.struct Ship

    ; 処理
    function_l          .byte
    function_h          .byte

    ; 生存
    alive               .byte

    ; 無敵
    nodamage            .byte

    ; 状態
    state               .byte

    ; 位置
    position_x          .byte
    position_y          .byte

    ; 直前の位置
    last_x              .byte
    last_y              .byte

    ; 移動
    move_x              .byte
;   move_y              .byte

    ; 描画
    render_draw         .byte
    render_erase        .byte

    ; アニメーション
    animation           .byte

    ; タイルセット
    tileset_l           .byte
    tileset_h           .byte

.endstruct
