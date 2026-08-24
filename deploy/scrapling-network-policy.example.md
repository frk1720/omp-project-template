# Scrapling MCP Network Policy

Dokumen ini adalah guard deployment, bukan allowlist otomatis di dalam Scrapling. Scrapling MCP menerima URL sebagai input tool; kontrol outbound harus ditegakkan oleh network layer atau proxy egress.

## Safe default lokal

- MCP bind hanya ke `127.0.0.1`.
- HTTP transport wajib memakai bearer token.
- `--allowed-host localhost:8000` mengaktifkan host/DNS-rebinding protection untuk endpoint MCP.
- Jangan memetakan port MCP langsung ke internet.

## SSRF controls wajib untuk deployment jaringan

1. Buat allowlist hostname target yang memang diperlukan, misalnya `docs.example.com` dan `api.example.com`.
2. Tegakkan allowlist pada egress proxy/firewall, bukan hanya pada prompt agent.
3. Hanya izinkan `https://` kecuali ada keputusan eksplisit untuk target lain.
4. Tolak loopback, link-local, private IPv4, unique-local IPv6, multicast, metadata IP, dan hostname internal.
5. Evaluasi seluruh hasil DNS dan cegah DNS rebinding/TOCTOU; gunakan proxy yang melakukan resolusi dan filtering saat koneksi.
6. Batasi redirect, timeout, response size, concurrency, dan content type.
7. Jalankan MCP sebagai user/container berprivilege minimum tanpa akses ke credential host.
8. Log hostname, status, latency, ukuran, dan keputusan allow/deny—tanpa URL query sensitif, cookie, token, atau response body.
9. Uji negative cases sebelum membuka akses jaringan.

## Release gate

Deployment jaringan **blocked** jika salah satu belum tersedia:

- Egress allowlist dan enforcement point.
- TLS termination.
- Authentication token dari secret manager.
- Allowed host policy.
- Monitoring dan audit log.
- Rollback/disable procedure.

Menjalankan `--no-auth`, bind `0.0.0.0`, atau mengandalkan `robots.txt` saja bukan SSRF protection.
