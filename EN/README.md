# FTW — File Transfer Wargame 🚩

An OverTheWire-style CTF wargame about moving files across the wire: download, serve, exfiltrate,
encode. You SSH into a box whose toolset is deliberately stripped down, and you use whatever
technique is left. Inside the file you pull is the password for the next level. **34 levels**
(0–33) in five parts + a fileserver = 35 containers.

![Logging into FTW — a level greets you with its brief on SSH login](../1.png)

## Run

```bash
cd EN
./gen-flags.sh                 # generate flag-passwords (required once)
docker compose up -d --build   # build & launch
docker compose down            # tear down
```

## Play

```bash
ssh level0@localhost -p 3220   # starting password: start-here
cat task.txt                   # the brief is always in ~/task.txt
```

Each level ships three files in `~`: **`task.txt`** (brief), **`hint.txt`**
(opt-in nudge), **`info.txt`** (tool deep-dive).

A level's port = **3220 + number**. The full walkthrough is in `SOLVES.md`.

| Part | Levels | About |
|------|--------|-------|
| 1 · Channels | 0–7 | scp · curl/wget · python · perl/php/ruby · gawk · /dev/tcp · netcat · tar\|nc |
| 2 · Encoding | 8–14 | base64/nc · base32 · hex · gzip · openssl AES · ncat --ssl · sha256 |
| 3 · Exotic | 15–19 | uuencode · XOR · split · UDP · socat |
| 4 · Compression/encodings | 20–27 | base85 · z85 · bzip2 · xz · zlib · UTF-16 · basenc×3 · octal |
| 5 · GHOST (hard) | 28–32 | enumeration · port scan · encoding recognition · strings · XOR brute |
| Finale | 33 | ✓ you cleared them all |

In the GHOST part the `task.txt` is nearly empty — the technique and the path are not given;
you enumerate the host yourself.

## fileserver (the "attacker box")
HTTP `:80`/`:1337` · SSH `:22` (SCP source, SFTP chroot) · nc `:4445-4447` · TLS `:4448` ·
UDP `:4449` · socat `:4450` · ghost `:9029`,`:9032`. Its ports aren't published to the host.
Flags are generated per run (`gen-flags.sh`) and git-ignored.

## Windows part
`certutil`, PowerShell IWR/IRM/WebClient/IEX, `Get-FileHash` aren't reproduced in containers
(Windows containers on Linux are impractical); they're covered in the companion web page.

---
Russian version: see the sibling `RU/` folder.

---

## System requirements

Deliberately light — one edition is 35 small containers sharing a common Debian base layer.

- **OS:** Linux with Docker Engine, or macOS/Windows with Docker Desktop.
- **Docker:** Engine ≥ 20.10 and Compose v2 (the `docker compose` subcommand).
- **CPU:** any x86-64 or arm64; 1 core works, 2+ makes the first build faster.
- **RAM:** ~100 MB at idle for all 35 containers; **1 GB free is comfortable**, 2 GB recommended
  during the parallel first build.
- **Disk:** ~2–3 GB for one edition's images (shared base keeps it small); ~4–5 GB if you build
  both EN and RU.
- **Network:** internet needed only on the first `docker compose up --build` (to pull the Debian
  base + apt packages). After that it runs fully offline.
- **Ports:** binds host TCP **3220–3253** (one SSH port per level). fileserver's ports stay internal.
