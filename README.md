# p - AWK like PHP wrapper for command line

## Special variable

 * User-modified variables:
   * **`$OFS`** - Output Field Separator *(default: ` `)* [AWK compatible]
   * **`$ORS`** - Output Record Separator *(default: `PHP_EOL`)* [AWK compatible]
 * Auto-set variables:
   * **`int $NR`** - The number of input records [AWK compatible]
   * **`int $FNR`** - The current record number in the current file [AWK compatible]
   * **`string $F0`**, `${0}` - Contains current line
   * **`string[] $F`** - Contains fields separated by `$OFS` [AWK compatible]
   * **`int $NF`** - The number of fields in `$F` [AWK compatible]
   * **`int $argi`** - Same as `$NR` [PHP compatible]
   * **`string $argn`** - Same as `$F0` [PHP compatible]
