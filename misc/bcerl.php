<?php
$test = "/path/to/bqn/test/cases/prim.bqn";
$compiler = "../misc/cerl.bqn";
$lines = explode("\n", file_get_contents($test));
foreach($lines as $line) {
    if (!is_int(strpos($line,"#")) && ! $line == '') {
        if (!is_int(strpos($line,'%'))) {
            $bqn = $line;
            $arg = escapeshellarg($bqn);
        }
        else {
            $pos = strpos($line,'%');
            $bqn = substr($line,1+$pos);
            $arg = escapeshellarg($bqn);
        }
        $cmd = "$compiler ".$arg;
        $out = shell_exec($cmd);
        if (!is_int(strpos($line,'%'))) {
            print_r("1 = ebqn:run(".trim($out)."), %".$bqn."\n");
        }
        else {
            print_r("ok = try ebqn:run(".trim($out).") %".$bqn."\n\tcatch _ -> ok\nend,\n");
        }
    }
    else {
        print_r("% $line\n");
    }
}

