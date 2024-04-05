# `charmap_w.inc`
RGBDS include file for wide charmap support

Since `rgbds` native `charmap` only supports 8-bit values now(`v0.7.0`), this inc file attempts to support wide-byte charmap without modifying rgbds.

See the `charmap_w.inc` file itself and the examples below for details.

# List of alternative macros
| Native Expressions | Alternative Macros | Notes                     |
|--------------------|--------------------|---------------------------|
| `newcharmap`       | `newcharmap_w`     |                           |
| `setcharmap`       | `setcharmap_w`     |                           |
| `pushc`            | `pushc_w`          |                           |
| `popc`             | `popc_w`           |                           |
| `charmap`          | `charmap_w`        |                           |
| `db`               | `db_w`             | Simple string recognition |
| `HIGH() / LOW()`   | `getchar_w`        | See examples              |
| `CHARLEN`          | `CHARLEN_w`        |                           |

# Exapmles

```
    ; Add wide charmap support to the default charmap
    newcharmap_w 2

    ; Define wide charmap
    charmap_w "T", $10, $11
    charmap_w "est", $12

    ; Use wide charmap
    db_w "Test"         ; db $10, $11, $12

    ; Mix with values
    db_w 9, "Test", $13 ; db $09, $10, $11, $12, $13

    ; Push wide charmap
    pushc_w

    ; Add new wide charmap and switch to it
    newcharmap_w 3, new_map_1
    charmap_w "Tes", $20, $21, $22

    ; Add new wide charmap, based on new_map_1
    newcharmap_w 4, new_map_2, new_map_1
    charmap_w "t", $23, $24, $25, $26
    db_w "Test"          ; db $20, $21, $22, $23, $24, $25, $26

    ; Pop wide charmap, now the default charmap
    popc_w

    ; Get the value of a character
    ; For rgbds that natively support 16-bit charmap:
    ; charmap "T", $1011
    ; ld b, $02
    ; ld a, HIGH("T") ; ld a, $10
    ; ld [hli], a
    ; ld a,  LOW("T") ; ld a, $11
    ; ld [hli], a

    ; For the native rgbds that work with charmap_w, they need to be replaced with:
    getchar_w "T", w_value, w_length
    ld b, w_length      ; ld b, $02
    ld a, HIGH(w_value) ; ld a, $10
    ld [hli], a
    ld a,  LOW(w_value) ; ld a, $11
    ld [hli], a

    ; Set wide charmap
    setcharmap_w new_map_2

    ; Get the length of a string
    charlen_w "Test", w_length
    ld hl, w_length ; ld hl, $07
```

# DB-compatible mode `CHARMAP_W_DB_COMPMODE` 

`CHARMAP_W_DB_COMPMODE` is used to configure the db-compatible mode.

All `newcharmap_w n, {name}` defines `newcharmap {name}` and `newcharmap CHARMAP_W_{name}_PLANE_{0..n}` and sets the charmap to `charmap {name}`.

The `PLANE` charmap is not affected by `COMPMODE` and is used in `_w` related functions.

The original `charmap {name}`, on the other hand, depending on the setting of `COMPMODE`, the contents of that charmap will change as follows:

- The default value is `1`, and in this configuration only 1-byte lengths of characters using charmap_w will actually be set to charmap, and wide char will only be set to the corresponding `PLANE` charmap. 
    - Using `db` instead of `db_w` can index 1-byte lengths of characters only.
    - If wide char misuses `db`, `rgbds` will report `Unmapped-char` warning.
- With a setting of `0`, all characters are not set to charmap.
- With a setting of `2`, the highest byte of all characters is set to charmap.

| value       | `charmap {name}`                | `CHARMAP_W_{name}_PLANE_{0..n}` |
|-------------|---------------------------------|---------------------------------|
| 0           | none                            | 1-byte chars and wide chars     |
| 1 (default) | 1-byte chars                    | 1-byte chars and wide chars     |
| 2           | 1-byte chars and wide chars (*) | 1-byte chars and wide chars     |

> (*): Only highest byte is set. `charmap_w "T", $12, $34` will only set `charmap "T", $12` to `charmap {name}`.

