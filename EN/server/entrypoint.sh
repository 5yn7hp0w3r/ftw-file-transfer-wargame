#!/bin/bash
set -e
F=/flags
say(){ echo "Password for level$1:"; cat "$F/level$1"; }

# ===== SCP (level0): scpuser jailed in chroot, sees ONLY level1.txt =====
echo "scpuser:scpflag" | chpasswd
mkdir -p /jail; chown root:root /jail && chmod 755 /jail
say 1 > /jail/level1.txt; chown root:root /jail/level1.txt && chmod 644 /jail/level1.txt
if ! grep -q "Match User scpuser" /etc/ssh/sshd_config; then
cat >> /etc/ssh/sshd_config <<'CFG'
Match User scpuser
  ChrootDirectory /jail
  ForceCommand internal-sftp
  AllowTcpForwarding no
  X11Forwarding no
  PermitTunnel no
CFG
fi

# ===== Part 1: HTTP plain (1..5) + tar (7) =====
mkdir -p /srv/www
for n in 1 2 3 4 5; do mkdir -p "/srv/www/level${n}"; { echo "### FTW // FILE TRANSFER WARGAME ###"; say $((n+1)); } > "/srv/www/level${n}/next.txt"; done
mkdir -p /srv/pack/loot; say 8 > /srv/pack/loot/flag.txt; echo "tar|nc pull." > /srv/pack/loot/README.txt

# ===== Part 2: encoding =====
mkdir -p /srv/www/level9;  say 10 | base32                                              > /srv/www/level9/next.b32
mkdir -p /srv/www/level10; say 11 | xxd -p                                              > /srv/www/level10/next.hex
mkdir -p /srv/www/level11; say 12 | gzip -c                                             > /srv/www/level11/next.gz
mkdir -p /srv/www/level12; say 13 | openssl enc -aes-256-cbc -pbkdf2 -salt -base64 -k transfer > /srv/www/level12/next.enc
mkdir -p /srv/www/level14; say 15 > /srv/www/level14/next.txt; ( cd /srv/www/level14 && sha256sum next.txt > next.txt.sha256 )

# ===== Part 3: exotic =====
mkdir -p /srv/www/level15; say 16 | uuencode secret.txt > /srv/www/level15/next.uu
mkdir -p /srv/www/level16; say 17 | python3 -c 'import sys;d=sys.stdin.buffer.read();sys.stdout.buffer.write(bytes(b^0x42 for b in d))' | base64 > /srv/www/level16/next.b64
mkdir -p /srv/www/level17; { echo "Reassemble the chunks in order."; say 18; } > /tmp/blob17; split -b 24 -d /tmp/blob17 /srv/www/level17/part.
say 20 > /srv/socatflag

# ===== Part 4: compression & tricky encodings =====
mkdir -p /srv/www/level20; say 21 | python3 -c 'import sys,base64;sys.stdout.buffer.write(base64.b85encode(sys.stdin.buffer.read()))' > /srv/www/level20/next.b85
mkdir -p /srv/www/level21; say 22 > /tmp/p21; while [ $(( $(wc -c </tmp/p21) % 4 )) -ne 0 ]; do printf ' ' >> /tmp/p21; done; basenc --z85 /tmp/p21 > /srv/www/level21/next.z85
mkdir -p /srv/www/level22; say 23 | bzip2 -c                                            > /srv/www/level22/next.bz2
mkdir -p /srv/www/level23; say 24 | xz -c                                               > /srv/www/level23/next.xz
mkdir -p /srv/www/level24; say 25 | python3 -c 'import sys,zlib;sys.stdout.buffer.write(zlib.compress(sys.stdin.buffer.read()))' > /srv/www/level24/next.zlib
mkdir -p /srv/www/level25; say 26 | iconv -f UTF-8 -t UTF-16LE                          > /srv/www/level25/next.utf16
mkdir -p /srv/www/level26; say 27 | basenc --base64url -w0 | basenc --base16 -w0 | basenc --base32 -w0 > /srv/www/level26/next.enc
mkdir -p /srv/www/level27; say 28 | python3 -c 'import sys;d=sys.stdin.buffer.read();sys.stdout.write("".join("\%03o"%b for b in d))' > /srv/www/level27/next.oct

# ===== Part 5: GHOST (28..32) =====
mkdir -p /srv/www/ghost
say 29 > /srv/www/ghost/28
say 31 | base64 > /srv/www/ghost/30
{ head -c 400 /dev/urandom | base64; echo "FLAG=$(cat "$F/level32")"; head -c 400 /dev/urandom | base64; } > /srv/www/ghost/dump.bin
say 33 | python3 -c 'import sys;d=sys.stdin.buffer.read();sys.stdout.buffer.write(bytes(b^0x5A for b in d))' > /srv/ghost5.bin

# ===== services =====
ssh-keygen -A >/dev/null 2>&1
/usr/sbin/sshd -e
python3 -m http.server 80   --directory /srv/www >/dev/null 2>&1 &
python3 -m http.server 1337 --directory /srv/www >/dev/null 2>&1 &
loop(){ while true; do eval "$1" || sleep 1; done; }
loop 'ncat -l 0.0.0.0 4445 --send-only < "$F/level7" >/dev/null 2>&1' &
loop 'tar czf - -C /srv pack 2>/dev/null | ncat -l 0.0.0.0 4446 --send-only >/dev/null 2>&1' &
loop 'say 9  | base64 | ncat -l 0.0.0.0 4447 --send-only >/dev/null 2>&1' &
loop 'say 14 | ncat --ssl -l 0.0.0.0 4448 --send-only >/dev/null 2>&1' &
# level18 UDP — persistent responder (UDP has no retransmit; a respawn loop races)
say 19 > /srv/udp19
python3 -c 'import socket
s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM);s.bind(("0.0.0.0",4449))
d=open("/srv/udp19","rb").read()
while 1:
    _,a=s.recvfrom(65535);s.sendto(d,a)' >/dev/null 2>&1 &
loop 'socat -u OPEN:/srv/socatflag TCP-LISTEN:4450,reuseaddr >/dev/null 2>&1' &
loop 'say 30 | ncat -l 0.0.0.0 9029 --send-only >/dev/null 2>&1' &
loop 'ncat -l 0.0.0.0 9032 --send-only < /srv/ghost5.bin >/dev/null 2>&1' &
echo "[fileserver] FTW up (parts 1-5, levels 0-33)"
wait
