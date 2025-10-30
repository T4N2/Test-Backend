<?php

$dir = __DIR__;
$inputFile = $dir . DIRECTORY_SEPARATOR . 'daftar_nama.txt';
$outputFile = $dir . DIRECTORY_SEPARATOR . 'hasil_sorting.txt';
if (!file_exists($inputFile)) {
	$sample = [
		"Zara",
		"Adam",
		"John",
		"Emily",
	];
	file_put_contents($inputFile, implode(PHP_EOL, $sample) . PHP_EOL);
	echo "Contoh `daftar_nama.txt` dibuat.\n";
}

if (!is_readable($inputFile)) {
	fwrite(STDERR, "File tidak dapat dibaca: $inputFile\n");
	exit(1);
}

$lines = file($inputFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
if ($lines === false) {
	fwrite(STDERR, "Gagal membaca file: $inputFile\n");
	exit(1);
}

$names = array_map('trim', $lines);
$names = array_filter($names, function ($v) { return $v !== ''; });

if (class_exists('Collator')) {
	$coll = new Collator('id_ID');
	$ok = $coll->sort($names);
	if (!$ok) {
		usort($names, 'strcasecmp');
	}
} else {
	usort($names, 'strcasecmp');
}

$html = <<<HTML
<?php
/**
 * hasil_sorting.php
 * Hasil sortir nama dari daftar_nama.txt
 */
?>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Hasil Sorting Nama</title>
  <style>body{font-family:system-ui,Arial,sans-serif;padding:16px}ul{line-height:1.6}</style>
</head>
<body>
  <h1>Hasil Sorting Nama</h1>
  <p>Diambil dari: <code>daftar_nama.txt</code></p>
  <ul>
HTML;


$txt = implode(PHP_EOL, $names) . PHP_EOL;

if (file_put_contents($outputFile, $txt) === false) {
	fwrite(STDERR, "Gagal menulis file output: $outputFile\n");
	exit(1);
}

echo "Sukses: ditulis " . count($names) . " nama ke $outputFile\n";
?>
