<?php
// Array aktivitas
$aktivitas = [
    'User_Login' => 'John Doe',
    'User_Logout' => 'John Doe',
    'User_Login' => 'Jane Smith'
];

// Hitung jumlah aktivitas
$totalAktivitas = count($aktivitas);

// Ambil tanggal saat ini
$tanggalSekarang = date('d-m-Y');

// Buat isi laporan
$laporan  = "Laporan Harian\n";
$laporan .= "Tanggal : $tanggalSekarang\n";
$laporan .= "Total Aktivitas : $totalAktivitas\n";

// Buat file dan tulis isi laporan ke report.txt
$file = 'report.txt';
file_put_contents($file, $laporan);
if (php_sapi_name() === 'cli' || defined('STDOUT')) {
    echo "File '$file' berhasil dibuat dengan isi berikut:" . PHP_EOL . PHP_EOL;
    echo $laporan . PHP_EOL;
} else {
    $safeFile = htmlspecialchars($file, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    $safeLaporan = htmlspecialchars($laporan, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
    echo "File '" . $safeFile . "' berhasil dibuat dengan isi berikut:<br><pre>" . $safeLaporan . "</pre>";
}
?>
