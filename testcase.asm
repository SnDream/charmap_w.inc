; TODO: Cleaning up test cases

; Compile:
; rgbasm testcase.asm -o t.o && rgblink -o t.bin t.o && hexdump -C t.bin

INCLUDE "charmap_w.inc"

SECTION "test0", ROM0
	newcharmap_w 2
	charmap_w "T", $01
	charmap_w "est", $02, $03
	charmap_w "<", $21
	charmap_w ">", $22
	;charmap_w "<est>", $04, $05, $06
	db_w "Test", $30, "T" + 4, "<est>"

SECTION "test1", ROM0[$10]
	newcharmap_w 3, test
	charmap_w "T", $11
	charmap_w "est", $12, $13
	charmap_w "<est>", $14, $15, $16
	db_w "Test", $30, 34 + 4, "<est>"

SECTION "test3", ROM0[$30]
	setcharmap_w main
	db_w "Test", $30, 34 + 4, "<est>"

SECTION "test4", ROM0[$40]
	println "opt {CHARMAP_W_NAME}"
	pushc_w
	println "opt {CHARMAP_W_NAME}"
	pushc_w
	println "opt {CHARMAP_W_NAME}"
	setcharmap_w test
	db_w "Test", $30, 34 + 4, "<est>"
	db_w "Test", $30, 34 + 4, "<est>"
	GETCHAR_w "est"
	println "getchar_w {CHARMAP_W_CHAR} {CHARMAP_W_CHARLEN}"
	GETCHAR_w "<est>", w_char_v
	println "getchar_w {w_char_v}"
	GETCHAR_w "est", w_char_v, w_char_l
	println "getchar_w {w_char_v} {w_char_l}"
	GETCHAR_w "<est>", w_char_v, w_char_l
	println "getchar_w {w_char_v} {w_char_l}"
	CHARLEN_w "Test<est>"
	println "CHARLEN_w {CHARMAP_W_CHARLEN}"
	CHARLEN_w "T<est>", w_char_l
	println "CHARLEN_w {w_char_l}"
	println "opt {CHARMAP_W_NAME}"
	popc_w
	println "opt {CHARMAP_W_NAME}"
	popc_w
	db_w "Test", $30, 34 + 4, "<est>"
	println "opt {CHARMAP_W_NAME}"
	
SECTION "test6", ROM0[$60]
	pushc_w
	newcharmap_w 4, test2, test
	db_w "estT", $30, 34 + 4, "<est>"
	
SECTION "test7", ROM0[$70]
	popc_w
	db_w "estT", $30, 34 + 4, "<est>"
