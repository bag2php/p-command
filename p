#!/usr/bin/env php
<?php

/**
 * p - AWK like PHP wrapper for command line
 *
 * @copyright 2019 USAMI Kenta
 * @author  USAMI Kenta
 * @license https://github.com/bag2php/p-command/blob/master/LICENSE MPL-2.0
 */
const BAG2_P_CMD_VERSION = '0.1.0';

$options = \getopt('d:f:v:B:E:F::R:', ['help', 'version'], $optind);
$rest_args = \count($argv) > $optind ? \array_slice($argv, $optind) : [];

$OFS = ' ';
$ORS = PHP_EOL;
$FS = '/\s/';

if (isset($options['help']) || isset($options['version'])) {
    echo 'p ', BAG2_P_CMD_VERSION, ' - ';
    echo 'AWK like PHP wrapper for command line ', \PHP_EOL;
    exit(1);
}

if (isset($options['F'])) {
    $FS = '/'. \implode('|', \array_map(function ($d) {
        return \preg_quote($d, '/');
    }, (array)$options['F'])) . '/';
}

foreach ((array)($options['d'] ?? []) as $def) {
    if (\strpos($def, '=') === false) {
        \ini_set($def, '1');
    } else {
        [$name, $value] = \explode('=', $def);
        \ini_set($name, $value);
    }
}
unset($def, $name, $value);

foreach ((array)($options['f'] ?? []) as $file) {
    include $file;
}
unset($file);

foreach ((array)($options['v'] ?? []) as $def) {
    if (\strpos($def, '=') === false) {
        $var = [$def => null];
    } else {
        [$name, $value] = \explode('=', $def);
        $var = [$name => $value];
    }

    \extract($var);
}

foreach ((array)($options['B'] ?? []) as $code) {
    eval($code . ';');
}
unset($code);

${"\0codes\0"} = \array_map(function($code) {
    if (\strpos($code, ':') === false) {
        return [
            'test' => 'return true;',
            'code' => "return {$code};"
        ];
    }

    throw new RuntimeException("Multiple statement NOT Supported yet.");
}, (array)($options['R'] ?? []));

${"\0files\0"} = ['-' => STDIN];

foreach ($rest_args as $a) {
    if (preg_match('/\A(?<test>[^{}]*){(?<code>.+)\}\z/', $a, $matches)) {
        $test = \trim($matches['test']);
        if ($test === '') {
            $test = 'true';
        } elseif (\preg_match('@\A/.+/\z@', $test)) {
            $test = \sprintf('\\preg_match(\'%s\', $argn)', strtr(
                $test,
                ['\\' => '\\\\', "'" => "\\'"]
            ));
        }

        ${"\0codes\0"}[] = [
            'test' => "return {$test};",
            'code' => "return {$matches['code']};",
        ];
    } else {
        ${"\0files\0"}[$a] = fopen($a, 'r');
    }
}
unset($rest_args, $a, $matches, $test);

${"\0output\0"} = function($value) use ($OFS): string {
    if ($value === null) {
        return '';
    }

    if (\is_string($value) || \is_int($value) || \is_float($value)) {
        return (string)$value;
    }

    if (\is_iterable($value)) {
        $values = [];
        foreach ($value as $v) {
            $values[] = (string)$v;
        }

        return \implode($OFS, $values);
    }

    return (string)$value;
};

$NR = 1;
foreach (${"\0files\0"} as $FILENAME => $fp) {
    $FNR = 1;
    while ($line = \fgets($fp)) {
        $argi = $NR;
        $argn = \rtrim($line, $ORS);
        $F0 = ${0} = $argn;
        $F = \preg_split($FS, $argn) ?: [];
        array_unshift($F, $F0);
        // extract($F, \EXTR_PREFIX_ALL, 'F');
        // extract($F, \EXTR_PREFIX_ALL);
        $NF = \count($F);

        foreach (${"\0codes\0"} as $c) {
            if (eval($c['test'])) {
                $_ = eval($c['code']);
            }
        }

        if (isset($_)) {
            echo ${"\0output\0"}($_), $ORS;
        }

        $FNR++;
        $NR++;
        unset($_);
    }
}

foreach ((array)($options['E'] ?? []) as $code) {
    eval($code . ';');
}
