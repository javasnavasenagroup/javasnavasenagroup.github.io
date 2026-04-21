CREATE DATABASE IF NOT EXISTS db_rumah_kebangsaan
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE db_rumah_kebangsaan;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE peran (
    id_peran    INT          AUTO_INCREMENT PRIMARY KEY,
    kode_peran  VARCHAR(50)  NOT NULL UNIQUE,
    nama_peran  VARCHAR(100) NOT NULL,
    deskripsi   VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE pengguna (
    id_pengguna     INT          AUTO_INCREMENT PRIMARY KEY,
    id_peran        INT          NOT NULL,
    nama_lengkap    VARCHAR(255) NOT NULL,
    username        VARCHAR(100) NOT NULL UNIQUE,
    email           VARCHAR(150) NOT NULL UNIQUE,
    kata_sandi      VARCHAR(255) NOT NULL,
    status_aktif    TINYINT(1)   DEFAULT 1,
    login_terakhir  TIMESTAMP    NULL,
    dibuat_pada     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_peran) REFERENCES peran(id_peran) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE token_reset_sandi (
    id_token    INT          AUTO_INCREMENT PRIMARY KEY,
    id_pengguna INT          NOT NULL,
    token       VARCHAR(255) NOT NULL UNIQUE,
    kadaluarsa  TIMESTAMP    NOT NULL,
    digunakan   TINYINT(1)   DEFAULT 0,
    dibuat_pada TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE berkas_file (
    id_file        INT          AUTO_INCREMENT PRIMARY KEY,
    id_pengunggah  INT          NULL,
    nama_file      VARCHAR(255) NOT NULL,
    path_file      VARCHAR(255) NOT NULL,
    ekstensi       VARCHAR(10)  NOT NULL,
    ukuran         BIGINT       NOT NULL,               -- [FIX] INT → BIGINT
    dibuat_pada    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengunggah) REFERENCES pengguna(id_pengguna) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE kategori_artikel (
    id_kategori   INT          AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL,
    slug          VARCHAR(100) NOT NULL UNIQUE,
    dibuat_pada   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE artikel (
    id_artikel        INT          AUTO_INCREMENT PRIMARY KEY,
    id_penulis        INT          NOT NULL,
    id_kategori       INT          NOT NULL,
    id_gambar_sampul  INT          NULL,
    judul             VARCHAR(255) NOT NULL,
    slug              VARCHAR(255) NOT NULL UNIQUE,
    isi_konten        TEXT         NOT NULL,
    meta_deskripsi    VARCHAR(160) NULL,
    jumlah_tayangan   INT          DEFAULT 0,         
    status_publikasi  ENUM('draft', 'terbit', 'arsip') DEFAULT 'draft',
    waktu_tayang      TIMESTAMP    NULL,
    dibuat_pada       TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    diperbarui_pada   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_penulis)       REFERENCES pengguna(id_pengguna)         ON DELETE RESTRICT,
    FOREIGN KEY (id_kategori)      REFERENCES kategori_artikel(id_kategori) ON DELETE RESTRICT,
    FOREIGN KEY (id_gambar_sampul) REFERENCES berkas_file(id_file)          ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE galeri (
    id_galeri   INT          AUTO_INCREMENT PRIMARY KEY,
    id_file     INT          NOT NULL,
    keterangan  VARCHAR(255),
    dibuat_pada TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_file) REFERENCES berkas_file(id_file) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE komentar (
    id_komentar    INT          AUTO_INCREMENT PRIMARY KEY,
    id_artikel     INT          NOT NULL,
    id_pengguna    INT          NULL,
    nama_tamu      VARCHAR(100) NULL,
    email_tamu     VARCHAR(150) NULL,
    isi_komentar   TEXT         NOT NULL,
    status_tampil  ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    id_moderator   INT          NULL,
    waktu_moderasi TIMESTAMP    NULL,
    dibuat_pada    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_artikel)   REFERENCES artikel(id_artikel)    ON DELETE CASCADE,
    FOREIGN KEY (id_pengguna)  REFERENCES pengguna(id_pengguna)  ON DELETE CASCADE,
    FOREIGN KEY (id_moderator) REFERENCES pengguna(id_pengguna)  ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE foto_tamu (
    id_foto_tamu   INT          AUTO_INCREMENT PRIMARY KEY,
    id_file        INT          NOT NULL,
    nama_tamu      VARCHAR(100) NOT NULL,
    email_tamu     VARCHAR(150) NULL,
    keterangan     VARCHAR(255),
    status_tampil  ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    id_moderator   INT          NULL,
    waktu_moderasi TIMESTAMP    NULL,
    dicatat_pada   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_file)      REFERENCES berkas_file(id_file)  ON DELETE CASCADE,
    FOREIGN KEY (id_moderator) REFERENCES pengguna(id_pengguna) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE ulasan (
    id_ulasan     INT          AUTO_INCREMENT PRIMARY KEY,
    nama_tamu     VARCHAR(100) NOT NULL,
    isi_ulasan    TEXT         NOT NULL,
    status_tampil ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    id_moderator  INT          NULL,
    dibuat_pada   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_moderator) REFERENCES pengguna(id_pengguna) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE log_aktivitas (
    id_log          INT          AUTO_INCREMENT PRIMARY KEY,
    id_pengguna     INT          NULL,
    jenis_aktivitas VARCHAR(100) NOT NULL,
    deskripsi       TEXT         NOT NULL,
    ip_address      VARCHAR(45)  NOT NULL,
    user_agent      VARCHAR(255) NULL,
    dicatat_pada    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pengguna) REFERENCES pengguna(id_pengguna) ON DELETE SET NULL  -- [FIX]
) ENGINE=InnoDB;

CREATE TABLE pengaturan_sistem (
    kunci           VARCHAR(100) PRIMARY KEY,
    nilai           TEXT         NOT NULL,
    deskripsi       VARCHAR(255) NULL,
    diperbarui_pada TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

ALTER TABLE artikel
    ADD INDEX idx_artikel_status_waktu (status_publikasi, waktu_tayang),
    ADD INDEX idx_artikel_penulis      (id_penulis),
    ADD INDEX idx_artikel_kategori     (id_kategori);

ALTER TABLE komentar
    ADD INDEX idx_komentar_artikel_status (id_artikel, status_tampil);

ALTER TABLE log_aktivitas
    ADD INDEX idx_log_pengguna_waktu (id_pengguna, dicatat_pada);

ALTER TABLE token_reset_sandi
    ADD INDEX idx_token_kadaluarsa (kadaluarsa);

INSERT INTO peran (kode_peran, nama_peran, deskripsi) VALUES
    ('superadmin',    'Super Admin',    'Akses penuh ke seluruh sistem'),
    ('admin_konten',  'Admin Konten',   'Kelola artikel, galeri, dan moderasi konten'),
    ('moderator',     'Moderator',      'Moderasi komentar, foto tamu, dan ulasan');

INSERT INTO kategori_artikel (nama_kategori, slug) VALUES
    ('Berita',        'berita'),
    ('Kegiatan',      'kegiatan'),
    ('Pengumuman',    'pengumuman'),
    ('Sejarah',       'sejarah'),
    ('Budaya',        'budaya');

INSERT INTO pengaturan_sistem (kunci, nilai, deskripsi) VALUES
    ('nama_situs',          'Rumah Kebangsaan',     'Nama situs yang ditampilkan'),
    ('email_kontak',        'info@rumahkebangsaan.id', 'Email kontak utama'),
    ('max_upload_mb',       '5',                    'Batas ukuran upload file (MB)'),
    ('moderasi_komentar',   '1',                    '1 = komentar harus disetujui dulu'),
    ('moderasi_foto_tamu',  '1',                    '1 = foto tamu harus disetujui dulu'),
    ('artikel_per_halaman', '10',                   'Jumlah artikel per halaman');