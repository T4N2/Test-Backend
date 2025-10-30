## Test-Backend

Repository ini berisi contoh aplikasi backend sederhana (Node.js/Express) beserta frontend statis dan beberapa contoh skrip PHP.

Deskripsi singkat

- Backend: aplikasi Express sederhana untuk manajemen produk dan penjualan.
- Frontend: file statis `frontend/index.html` (demo/entry point sederhana).
- PHP: folder `PHP/` berisi beberapa skrip dan contoh file latihan.

Struktur proyek

- `backend/` - kode server Node.js
  - `app.js` - entry point aplikasi
  - `db.js` - konfigurasi koneksi database (MySQL)
  - `routes/` - rute API (`auth.js`, `products.js`, `sales.js`)
  - `middleware/auth.js` - middleware otentikasi JWT
  - `product_sales.sql` - contoh SQL untuk data/struktur
- `frontend/` - file frontend statis
- `PHP/` - contoh skrip PHP dan data latihan

Prasyarat

- Node.js (v14+ direkomendasikan)
- npm (biasa ikut terpasang dengan Node.js)
- MySQL jika ingin menggunakan database lokal sesuai `product_sales.sql`

Instalasi & Menjalankan (PowerShell / Windows)

1. Buka terminal PowerShell di folder `backend`:

```powershell
cd d:/Test-Backend/backend
```

2. Install dependensi:

```powershell
npm install
```

3. Menjalankan server:

```powershell
npm start
# Atau secara langsung: node app.js
```

Server default menjalankan `node app.js` (lihat `backend/package.json` script `start`).

Mengakses frontend

Frontend statis ada di `frontend/index.html`. Untuk menguji cepat, buka file tersebut di browser (double-click) atau jalankan server statis sederhana.

Database

File `backend/product_sales.sql` berisi contoh skrip untuk membuat/mengisi tabel. Gunakan MySQL/MariaDB untuk import jika perlu.

API (rute yang ada)

Berikut daftar rute yang ada (cek implementasi di `backend/routes`):

- `routes/auth.js` - endpoint untuk login / autentikasi (menghasilkan JWT)
- `routes/products.js` - endpoint untuk operasi CRUD produk
- `routes/sales.js` - endpoint untuk mencatat dan mengambil data penjualan

Middleware

`backend/middleware/auth.js` adalah middleware JWT yang digunakan untuk melindungi rute yang memerlukan otentikasi.

Konfigurasi lingkungan

- Periksa `db.js` untuk konfigurasi koneksi MySQL. Jika diperlukan, sesuaikan host, user, password, dan database.

Pengembangan

- Gunakan editor/IDE pilihan Anda.
- Menambahkan fitur: tambahkan route baru di `backend/routes` dan import di `app.js`.

File penting

- `backend/app.js` - file entry point server
- `backend/package.json` - daftar dependency dan script (start: `node app.js`)
- `backend/db.js` - konfigurasi DB

Lisensi

Project ini tidak menyertakan lisensi spesifik. Jika ingin dipublikasikan, pertimbangkan menambahkan `LICENSE` (contoh: MIT).

Kontak / Catatan

Jika butuh tambahan dokumentasi endpoint (contoh payload, respons, atau Postman collection), beri tahu saya dan saya akan tambahkan.

---

README dihasilkan otomatis — bisa diedit untuk menambahkan detail lingkungan spesifik (contoh variabel lingkungan, instruksi migrasi SQL, atau contoh request/response API).
