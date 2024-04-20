; bomb.s - 爆発
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
.include    "bomb.inc"


; コードの定義
;
.segment    "APP"

; タイルセット
;
.global _bomb_tileset_s_0
_bomb_tileset_s_0:
    .incbin     "resources/sprites/bomb-s_0.ptn"
.global _bomb_tileset_s_1
_bomb_tileset_s_1:
    .incbin     "resources/sprites/bomb-s_1.ptn"
.global _bomb_tileset_s_2
_bomb_tileset_s_2:
    .incbin     "resources/sprites/bomb-s_2.ptn"
.global _bomb_tileset_a_0
_bomb_tileset_a_0:
    .incbin     "resources/sprites/bomb-a_0.ptn"
.global _bomb_tileset_a_1
_bomb_tileset_a_1:
    .incbin     "resources/sprites/bomb-a_1.ptn"
.global _bomb_tileset_a_2
_bomb_tileset_a_2:
    .incbin     "resources/sprites/bomb-a_2.ptn"


; データの定義
;
.segment    "BSS"

