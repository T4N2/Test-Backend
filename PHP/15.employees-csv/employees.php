<?php

$csvFile = __DIR__ . DIRECTORY_SEPARATOR . 'employees.csv';
$delimiter = ';';

$errors = [];
$success = null;

// Baca file CSV
function readCsv($file, $delimiter = ';') {
    $rows = [];
    if (!file_exists($file)) return $rows;
    if (($h = fopen($file, 'r')) !== false) {
        while (($data = fgetcsv($h, 0, $delimiter)) !== false) {
            // skip empty lines
            if (count($data) === 1 && trim($data[0]) === '') continue;
            $rows[] = $data;
        }
        fclose($h);
    }
    return $rows;
}

$rows = readCsv($csvFile, $delimiter);

$header = [];
if (count($rows) > 0) {
    $header = $rows[0];
    $dataRows = array_slice($rows, 1);
} else {
    $dataRows = [];
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = isset($_POST['id']) ? trim($_POST['id']) : '';
    $name = isset($_POST['name']) ? trim($_POST['name']) : '';
    $position = isset($_POST['position']) ? trim($_POST['position']) : '';
    $salary = isset($_POST['salary']) ? trim($_POST['salary']) : '';

    if ($name === '' || $position === '' || $salary === '') {
        $errors[] = 'Semua kolom selain ID wajib diisi (Name, Position, Salary).';
    }

    $existingIds = array_map(function($r){ return isset($r[0]) ? $r[0] : null; }, $dataRows);
    $maxId = 0;
    foreach ($existingIds as $ex) {
        if (is_numeric($ex) && intval($ex) > $maxId) $maxId = intval($ex);
    }
    if ($id === '' || !is_numeric($id)) {
        $id = $maxId + 1;
    } else {
        if (in_array(strval($id), $existingIds, true)) {
            $errors[] = 'ID sudah ada, gunakan ID lain atau kosongkan kolom ID agar auto-increment.';
        }
    }

    if (empty($errors)) {
        $line = [$id, $name, $position, $salary];
        $out = fopen($csvFile, 'a');
        if ($out !== false) {
            fputcsv($out, $line, $delimiter);
            fclose($out);
            header('Location: ' . basename(__FILE__) . '?added=1');
            exit;
        } else {
            $errors[] = 'Gagal membuka file untuk penulisan.';
        }
    }
}

$rows = readCsv($csvFile, $delimiter);
if (count($rows) > 0) {
    $header = $rows[0];
    $dataRows = array_slice($rows, 1);
} else {
    $header = ['ID','Nama','Posisi','Gaji'];
    $dataRows = [];
}
function e($s) { return htmlspecialchars($s, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }

?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
        <title>Employees - CSV</title>

        <script src="https://cdn.tailwindcss.com"></script>
        <style>

            .table-wrap { max-width: 900px; }
        </style>
</head>
<body class="bg-slate-50 text-slate-800">
        <div class="max-w-4xl mx-auto py-10 px-4">
            <header class="flex items-center justify-between mb-6">
                <h1 class="text-2xl font-semibold">Employees</h1>
            </header>

    <?php if (!empty($_GET['added'])): ?>
        <div class="mb-4 rounded-md bg-green-50 border border-green-100 text-green-800 px-4 py-2">Data berhasil ditambahkan.</div>
    <?php endif; ?>

    <?php if (!empty($errors)): ?>
        <div class="mb-4 rounded-md bg-rose-50 border border-rose-100 text-rose-800 px-4 py-2"><pre class="whitespace-pre-wrap"><?php echo e(implode("\n", $errors)); ?></pre></div>
    <?php endif; ?>

    <h2 class="text-lg font-medium mt-4 mb-2">Daftar Karyawan</h2>
    <div class="table-wrap overflow-hidden rounded-lg shadow">
    <table class="min-w-full divide-y divide-slate-200 bg-white">
        <thead>
            <tr>
                <?php foreach ($header as $h): ?>
                    <th class="px-4 py-3 text-left text-sm font-medium text-slate-600"><?php echo e($h); ?></th>
                <?php endforeach; ?>
            </tr>
        </thead>
        <tbody>
            <?php if (empty($dataRows)): ?>
                <tr><td colspan="<?php echo count($header); ?>" class="px-4 py-3">Tidak ada data</td></tr>
            <?php else: ?>
                <?php foreach ($dataRows as $r): ?>
                    <tr class="odd:bg-white even:bg-slate-50">
                        <?php foreach ($r as $c): ?>
                            <td class="px-4 py-3 text-sm text-slate-700"><?php echo e($c); ?></td>
                        <?php endforeach; ?>
                    </tr>
                <?php endforeach; ?>
            <?php endif; ?>
        </tbody>
    </table>
    </div>

    <h2 class="text-lg font-medium mt-6 mb-2">Tambah Karyawan</h2>
    <form method="post" action="<?php echo e(basename(__FILE__)); ?>" class="space-y-3 bg-white p-4 rounded shadow">
        <div>
            <label class="block text-sm text-slate-600">ID <span class="text-xs text-slate-400">(kosongkan untuk auto)</span></label>
            <input name="id" class="mt-1 block w-full border rounded-md px-3 py-2" />
        </div>
        <div>
            <label class="block text-sm text-slate-600">Nama</label>
            <input name="name" required class="mt-1 block w-full border rounded-md px-3 py-2" />
        </div>
        <div>
            <label class="block text-sm text-slate-600">Posisi</label>
            <input name="position" required class="mt-1 block w-full border rounded-md px-3 py-2" />
        </div>
        <div>
            <label class="block text-sm text-slate-600">Gaji</label>
            <input name="salary" required class="mt-1 block w-full border rounded-md px-3 py-2" />
        </div>
        <div>
            <button type="submit" class="inline-flex items-center gap-2 bg-sky-600 text-white px-4 py-2 rounded-md hover:bg-sky-700">Tambah</button>
        </div>
    </form>

    </div>

</body>
</html>
