#!/bin/bash
set -e
U="level${LEVEL}"

# Login password = ONLY this level's own flag (single file mounted at /flag).
if [ -f /flag ]; then
    echo "${U}:$(cat /flag)" | chpasswd
fi

# Level task -> home dir + motd. NOTE: motd is printed ONCE, by PAM (pam_motd);
# sshd's own PrintMotd is set to 'no' below to avoid printing it a second time.
if [ -f /task/task.txt ]; then
    cp /task/task.txt "/home/${U}/task.txt"
    chown "${U}:${U}" "/home/${U}/task.txt"
    cp /task/task.txt /etc/motd
fi
# Optional hint -> home dir. The player opts in:  cat hint.txt
if [ -f /task/hint.txt ]; then
    cp /task/hint.txt "/home/${U}/hint.txt"
    chown "${U}:${U}" "/home/${U}/hint.txt"
fi

# Optional deep-dive -> home dir. The curious opt in:  cat info.txt
if [ -f /task/info.txt ]; then
    cp /task/info.txt "/home/${U}/info.txt"
    chown "${U}:${U}" "/home/${U}/info.txt"
fi

# hide entrypoint from the player
chmod 700 /entrypoint.sh 2>/dev/null || true

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/'                 /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/'  /etc/ssh/sshd_config
sed -i 's/^#\?PrintMotd.*/PrintMotd no/'                             /etc/ssh/sshd_config
ssh-keygen -A >/dev/null 2>&1

echo "[level${LEVEL}] sshd up (login: ${U})"
exec /usr/sbin/sshd -D -e
