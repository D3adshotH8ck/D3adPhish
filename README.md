# D3adPhish

> Hardened, fingerprint-stripped GoPhish build for penetration testers.  
> Built by [D3adshot](https://github.com/D3adshotH8ck)

![License](https://img.shields.io/badge/License-MIT-7f77dd?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Linux-555555?style=for-the-badge&logo=linux&logoColor=white)
![GoPhish](https://img.shields.io/badge/Based_on-GoPhish_v0.12.1-FF6633?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-00b894?style=for-the-badge)

---

## `// disclaimer`

> This tool is intended **exclusively** for authorized penetration testing and security awareness engagements. You must have **written permission** from the target organization before conducting any phishing simulation. Unauthorized use is illegal. The author accepts no liability for misuse.

---

## `// what is D3adPhish?`

GoPhish is the industry standard for phishing simulations , but out of the box it announces itself to every blue team and email gateway that knows what to look for.

D3adPhish patches the GoPhish source to strip all detectable fingerprints before compiling, producing a hardened binary ready for professional engagements.

---

## `// patches applied`

| Fingerprint | Default | Patched |
|-------------|---------|---------|
| `X-Mailer` email header | `gophish` | Removed |
| `X-Gophish-Contact` header | Present | Removed |
| URL tracking parameter | `?rid=` | `?utm_id=` |
| Server name identifier | `gophish` | `MSFT_MailService` |
| Session cookie name | `gophish` | `session` |
| Test email body | References gophish | Cleaned |

---

## `// requirements`

- Linux (Kali, Parrot, Ubuntu, Debian)
- `git`
- `go` (1.18+)
- `gcc` (for SQLite compilation)

```bash
sudo apt install git golang gcc -y
```

---

## `// installation`

```bash
# Clone D3adPhish
git clone https://github.com/D3adshotH8ck/D3adPhish
cd D3adPhish

# Run the patch and build script
chmod +x patch.sh
./patch.sh
```

The script will:
1. Clone the official GoPhish source
2. Apply all fingerprint patches
3. Compile a hardened binary: `gophish_hardened`

---

## `// usage`

```bash
# Run the hardened binary
sudo ./gophish_hardened
```

On first launch, your admin credentials will be printed to the terminal:

```
time="..." level=info msg="Please login with the username admin and the password <RANDOM_PASSWORD>"
```

Admin panel: `https://127.0.0.1:3333`  
Phishing listener: `http://0.0.0.0:80`

---

## `// hardening config.json`

Replace the default `config.json` with this template:

```json
{
  "admin_server": {
    "listen_url": "127.0.0.1:3333",
    "use_tls": true,
    "cert_path": "gophish_admin.crt",
    "key_path": "gophish_admin.key",
    "trusted_origins": []
  },
  "phish_server": {
    "listen_url": "0.0.0.0:443",
    "use_tls": true,
    "cert_path": "/etc/letsencrypt/live/yourdomain.com/fullchain.pem",
    "key_path": "/etc/letsencrypt/live/yourdomain.com/privkey.pem"
  },
  "db_name": "sqlite3",
  "db_path": "gophish.db",
  "migrations_prefix": "db/db_",
  "contact_address": "you@yourdomain.com",
  "logging": {
    "filename": "gophish.log",
    "level": "info"
  }
}
```

---

## `// opsec recommendations`

- Never run GoPhish directly from your own IP , use a VPS with an aged domain
- Set up proper SPF, DKIM, and DMARC records on your phishing domain
- Use an Apache/Nginx redirector in front of GoPhish to hide your server IP
- Always obtain a Let's Encrypt TLS cert — self-signed certs kill click rates
- Keep the admin panel (`3333`) firewalled — never expose it to the internet
- Get written authorization before every engagement — no exceptions

---

## `// based on`

[GoPhish](https://github.com/gophish/gophish) by Jordan Wright - MIT License

---

## `// license`

MIT License - see [LICENSE](LICENSE)

---

<div align="center">
<sub>// stay in the shadows. stay authorized. — D3adshot //</sub>
</div>
