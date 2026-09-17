#!/bin/bash
set -e
U="level${LEVEL}"

# Пароль на вход = ТОЛЬКО свой флаг (монтируется одним файлом в /flag).
# Каталога с чужими флагами в контейнере нет вообще.
if [ -f /flag ]; then
    echo "${U}:$(cat /flag)" | chpasswd
fi
# скрыть свой же флаг от игрока (он и так знает пароль, которым вошёл)
[ -f /flag ] && { cp /flag /root/.flagcopy 2>/dev/null || true; }

# Задание уровня -> в домашку и в motd
if [ -f /task/task.txt ]; then
    cp /task/task.txt "/home/${U}/task.txt"
    chown "${U}:${U}" "/home/${U}/task.txt"
    cp /task/task.txt /etc/motd
fi

# entrypoint не должен читаться игроком (скрывает механику)
chmod 700 /entrypoint.sh 2>/dev/null || true

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/'                 /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/'  /etc/ssh/sshd_config
sed -i 's/^#\?PrintMotd.*/PrintMotd yes/'                            /etc/ssh/sshd_config
ssh-keygen -A >/dev/null 2>&1

echo "[level${LEVEL}] sshd up (login: ${U})"
exec /usr/sbin/sshd -D -e
