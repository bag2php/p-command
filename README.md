# p - AWK like PHP wrapper for command line

`p` command is inspired by [AWK], [rb] and [py].

[AWK]: http://www.awklang.org/
[rb]: https://github.com/thisredone/rb
[py]: https://github.com/ryuichiueda/py

## Special variable

 * User-modified variables:
   * **`string $OFS`** - Output Field Separator *(default: ` `)* [AWK compatible]
   * **`string $ORS`** - Output Record Separator *(default: `PHP_EOL`)* [AWK compatible]
 * Auto-set variables:
   * **`int $NR`** - The number of input records [AWK compatible]
   * **`int $FNR`** - The current record number in the current file [AWK compatible]
   * **`string $F0`** - Contains current line
   * **`string[] $F`** - Contains fields separated by `$OFS` [AWK compatible]
   * **`int $NF`** - The number of fields in `$F` [AWK compatible]
   * **`int $argi`** - Same as `$NR` [PHP compatible]
   * **`string $argn`** - Same as `$F0` [PHP compatible]
