<?php
if (count($argv) !== 3) {
    print("usage: php misc/bcerl.php /path/to/mlochbaum/bqn testsname\n");
    exit;
};
$mbqn = $argv[1];
$testname = $argv[2];
$test = "$mbqn/test/cases/$testname.bqn";
$compiler = "./misc/cerl.bqn";
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
        $cmd = "$compiler $mbqn ".$arg;
        $out = shell_exec($cmd);
        if (is_int(strpos($line,'%')) && is_int(strpos($line,"!"))) {
            print_r("ok = try ebqn:run(St0,".trim($out).") %".$bqn."\n\tcatch _ -> ok\nend,\n");
        }
        else if (is_int(strpos($line,'%')) && strpos($line,"!")!==0) {
            $exp = trim(substr($line,0,strpos($line,"%",0)));
            print_r("{_,$exp} = ebqn:run(St0,".trim($out)."), %".$bqn."\n");
        }
        else {
            print_r("{_,1} = ebqn:run(St0,".trim($out)."), %".$bqn."\n");
        }
    }
    else {
        print_r("% $line\n");
    }
}

