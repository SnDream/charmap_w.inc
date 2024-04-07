# `charmap_w.inc`
宽字符 RGBDS 头文件

由于 `rgbds` 原生的 `charmap` (字符映射) 当前(`v0.7.0`)只支持8位数值，这个头文件尝试在不修改rgbds的情况下支持宽字节。

检查 `charmap_w.inc` 文件本身和下面的例子获取细节。

# 替代宏列表
| 原生表达式         | 替代宏             | 备注                      |
|--------------------|--------------------|---------------------------|
| `newcharmap`       | `newcharmap_w`     |                           |
| `setcharmap`       | `setcharmap_w`     |                           |
| `pushc`            | `pushc_w`          |                           |
| `popc`             | `popc_w`           |                           |
| `charmap`          | `charmap_w`        |                           |
| `db`               | `db_w`             | 支持基本的字符串类型检查  |
| `HIGH() / LOW()`   | `getchar_w`        | 见例子                    |
| `CHARLEN`          | `CHARLEN_w`        |                           |

# 例子

```
    ; 添加宽字节charmap支持到默认charmap
    newcharmap_w 2

    ; 定义宽字节字符
    charmap_w "测", $10, $11
    charmap_w "试文本", $12

    ; 使用宽字节字符串
    db_w "测试文本"         ; db $10, $11, $12

    ; 与数值混合使用
    db_w 9, "测试文本", $13 ; db $09, $10, $11, $12, $13

    ; 宽字节charmap压栈
    pushc_w

    ; 增加新宽字节charmap并切换
    newcharmap_w 3, new_map_1
    charmap_w "测试文", $20, $21, $22

    ; 基于 new_map_1 增加新宽字节charmap并切换
    newcharmap_w 4, new_map_2, new_map_1
    charmap_w "本", $23, $24, $25, $26
    db_w "测试文本"          ; db $20, $21, $22, $23, $24, $25, $26

    ; 宽字节charmap出栈，现在是默认charmap
    popc_w

    ; 获取字符的数值
    ; 对于原生支持16位charmap的rgbds，可以这么写:
    ; charmap "测", $1011
    ; ld b, $02
    ; ld a, HIGH("测") ; ld a, $10
    ; ld [hli], a
    ; ld a,  LOW("测") ; ld a, $11
    ; ld [hli], a

    ; 对于与charmap_w一起使用的原生rgbds，需要用下面的方式替换:
    getchar_w "测", w_value, w_length
    ld b, w_length      ; ld b, $02
    ld a, HIGH(w_value) ; ld a, $10
    ld [hli], a
    ld a,  LOW(w_value) ; ld a, $11
    ld [hli], a

    ; 设置宽字节charmap
    setcharmap_w new_map_2

    ; 获取字符串长度
    charlen_w "测试文本", w_length
    ld hl, w_length ; ld hl, $07
```

# DB兼容模式 `CHARMAP_W_DB_COMPMODE` 

`CHARMAP_W_DB_COMPMODE` 用于配置 db 兼容模式。

所有的 `newcharmap_w n, {name}` 均会定义 `newcharmap {name}` 和 `newcharmap CHARMAP_W_{name}_PLANE_{0..n}` ，并设置当前的charmap到 `charmap {name}` 。

`PLANE` charmap 不受 `CHARMAP_W_DB_COMPMODE` 影响，并被 `*_w` 相关的宏使用。

另一方面，原始 `charmap {name}` 根据 `CHARMAP_W_DB_COMPMODE` 的设置，具体内容依下面的方式变化：

- 默认值为 `1` ，这个配置下，使用 charmap_w 的字符，只有1字节长度的会真正设置到 `charmap {name}` ，宽字符只会设置到对应的 `PLANE` charmap。
    - 使用 `db` 代替 `db_w` 时，只有1字节长度的字符会被索引到。
    - 如果宽字节误用了 `db` ， `rgbds` 将报告 `Unmapped-char` 告警。
- 设置为 `0` 时，所有的字符都不会设置到 `charmap {name}` 。
- 设置为 `2` 时，每个字符的最高字节都会设置到 `charmap {name}` 。

| 值          | `charmap {name}`                | `CHARMAP_W_{name}_PLANE_{0..n}` |
|-------------|---------------------------------|---------------------------------|
| 0           | 无                              | 1字节长度字符和宽字节字符       |
| 1 (默认值)  | 1字节长度字符                   | 1字节长度字符和宽字节字符       |
| 2           | 1字节长度字符和宽字节字符 (*)   | 1字节长度字符和宽字节字符       |

> (*): 只会设置最高字节。 `charmap_w "T", $12, $34` 只会设置 `charmap "T", $12` 到 `charmap {name}`.

# `charmap_w.inc` 内容说明

## `newcharmap_w max_length, [name], [basename]`
```
; 创建一个新，空白的，叫name的charmap并切换到该charmap。 - 宽字节版本
; 
; max_length: 定义charmap的最大长度。
;             实际定义的字符可以少于这个长度。
;
; name      : 如果<未定义>，将宽字符charmap支持添加到默认charmap。
;
; basename  : 如果定义，从叫basename的charmap复制。
```

## `setcharmap_w name`
```
; 切换到叫name的charmap。 - 宽字节版本
```

## `pushc_w`
```
; 将当前的charmap推入栈里。 - 宽字节版本
```

## `popc_w`
```
; 从栈中弹出一个charmap，并切换到该charmap。 - 宽字节版本
```

## `charmap_w` "Strings", value1, ..., valueN
```
; 映射字符串到任意数值 (而不仅仅限定8位数值)
; 数值长度不允许大于charmap_w的最大长度。
; ```
; charmap_w "Example", $10, $20
; ```
```

## `db_w value1/"string1", ..., valueN/"stringN"`
```
; 定义一系列存储到最终镜像中的字节序列。
;
; 像原生的db那样工作，但是为字符串添加宽字符支持。
;
; 需要引号(")标记在参数的前面和后面，才能识别为文本。
; ```
; charmap_w "测", $23, $45
; charmap_w "试文本", $67
; db_w $FF, "测试文本", 0 ; 解析为 db $FF, $23, $45, $67, $00
; ```
; 类似 `db_w "测试文本" + 1` 或者 `db_w STRCAT("测试文本1", "测试文本2")` 的语法将警告，
; 而 "测试文本" 将只会强制视为8位数值。
;
; 如果只使用charmap中的8位数值，
; 你可以直接使用原生的db。（见CHARMAP_W_DB_COMPMODE）
```

## `getchar_w "Char", [value], [length]`
```
; 获取字符的数值和长度。
; 数值将设置到 CHARMAP_W_CHAR ，
; 长度将设置到 CHARMAP_W_CHARLEN 。
;
; value: 如果有定义，将 CHARMAP_W_CHAR 复制到 value 。
;
; length: 如果有定义，将 CHARMAP_W_CHARLEN 复制到 length 。
;
; 由于 HIGH()/LOW() 不能重写为宏，使用这个宏替代。
; 
; 对于原生支持16位charmap的rgbds，可以这么写:
; ```
; charmap "Text", $1234
; ld a, HIGH("Text") ; 解析为 $12
; ```
; 对于与charmap_w一起使用的原生rgbds，需要用下面的方式替换:
; ```
; charmap_w "Text", $12, $34
; getchar_w "Text", value
; ld a, HIGH(value) ; 解析为 $12
; ```
```

## `getchar_w "String", [value]`
```
; 获取字符串长度，长度将设置到 CHARMAP_W_CHARLEN 。
;
; length: 如果有定义，将 CHARMAP_W_CHARLEN 复制到 length 。
```
