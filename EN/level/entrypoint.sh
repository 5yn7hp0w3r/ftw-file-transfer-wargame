#!/bin/bash
set -e
U="level${LEVEL}"

# Login password = ONLY this level's own flag (mounted as a single file at /flag).
# There is no directory of other levels' flags inside the container.
if [ -f /flag ]; then
    echo "${U}:$(cat /flag)" | chpasswd
fi

# Level task -> home dir and motd
if [ -f /task/task.txt ]; then
    cp /task/task.txt "/home/${U}/task.txt"
    chown "${U}:${U}" "/home/${U}/task.txt"
    cp /task/task.txt /etc/motd
fi

# hide entrypoint from the player (keeps the mechanism opaque)
chmod 700 /entrypoint.sh 2>/dev/null || true

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/'                 /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/'  /etc/ssh/sshd_config
sed -i 's/^#\?PrintMotd.*/PrintMotd yes/'                            /etc/ssh/sshd_config
ssh-keygen -A >/dev/null 2>&1

echo "[level${LEVEL}] sshd up (login: ${U})"
exec /usr/sbin/sshd -D -e
