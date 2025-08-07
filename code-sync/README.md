# Code Sync Toolkit

Два проверенных варианта, чтобы без мессенджеров синхронизировать код между домашним и рабочим ПК:

- Вариант A (рекомендуется, проще): Syncthing — P2P синхронизация любой папки, шифрование, версионность, без облака.
- Вариант B: Git через приватную сеть (Tailscale) — собственный Git-репозиторий на домашнем ПК, push/pull с рабочего ПК.

Оба варианта не требуют доступа к ChatGPT на работе и работают поверх обычного интернета.

## Вариант A: Syncthing (P2P)

Подходит, если хотите просто «общую папку» с авто‑синком и версионностью файлов. Git можно использовать поверх (рекомендуется), но не обязателен.

### Установка (Linux)
Запустите по очереди на каждом ПК:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/syncthing/syncthing/main/packaging/scripts/syncthing-install.sh)
```

Либо воспользуйтесь нашими скриптами:

```bash
chmod +x syncthing/install_syncthing_linux.sh
./syncthing/install_syncthing_linux.sh
```

Включите автозапуск как user‑сервис:

```bash
./syncthing/syncthing_service_enable.sh
```

Syncthing Web UI: http://127.0.0.1:8384

### Настройка папки
1. На обоих ПК создайте папку для синхронизации, например `~/code-sync`:
   ```bash
   mkdir -p "$HOME/code-sync"
   ```
2. В Web UI на домашнем ПК добавьте папку `~/code-sync` (плюс «папка»), включите File Versioning (Simple/Trash Can) по вкусу.
3. Скопируйте Device ID рабочего ПК (в Web UI), добавьте устройство и поделитесь с ним папкой.
4. Примите приглашение на рабочем ПК. Готово — папка будет синхронизироваться.

### Windows / macOS
- Windows: установщик с сайта Syncthing (`https://syncthing.net`), автозапуск через планировщик или NSSM.
- macOS: `brew install syncthing && brew services start syncthing`.

## Вариант B: Git через Tailscale (собственный Git‑сервер дома)

Подходит, если рабочий процесс — через Git и важны ревью/ветки/коммиты. Данные остаются у вас, доступ по приватной сети Tailscale.

### Шаг 1. Установка Tailscale (оба ПК)
Linux:
```bash
chmod +x tailscale/install_tailscale_linux.sh
./tailscale/install_tailscale_linux.sh
```
Затем авторизуйтесь по ссылке, команда подскажет.

Windows/macOS: установите клиент Tailscale с сайта и войдите в аккаунт.

Проверьте, что оба устройства видят друг друга:
```bash
tailscale status | cat
```

### Шаг 2. Домашний ПК — развёртывание bare‑репозитория
```bash
sudo bash git/setup_home_git_server.sh myproject
```
Скрипт:
- создаст системного пользователя `git` (без shell);
- сгенерирует SSH ключ (или использует ваш);
- создаст репозиторий `/srv/git/myproject.git` (bare);
- выведет путь к публичному ключу для добавления на рабочем ПК.

### Шаг 3. Рабочий ПК — добавление удалённого репозитория
В каталоге вашего проекта:
```bash
bash git/add_remote_on_work.sh myproject <TAILSCALE_IP_HOME>
```
Пример:
```bash
bash git/add_remote_on_work.sh myproject 100.101.102.103
```
Это добавит `origin` вида:
`ssh://git@100.101.102.103/srv/git/myproject.git`

Дальше обычный Git‑поток:
```bash
git push -u origin main
# и затем git pull / git push
```

### Где взять Tailscale IP дом. ПК?
На домашнем ПК:
```bash
tailscale ip -4 | head -n1 | cat
```

## Что выбрать?
- Хотите «как папка Dropbox», без доп. инструментов — берите Syncthing.
- Используете Git и хотите full‑git без облака — берите Tailscale+Git.

## Структура
```
code-sync/
  README.md
  syncthing/
    install_syncthing_linux.sh
    syncthing_service_enable.sh
  tailscale/
    install_tailscale_linux.sh
  git/
    setup_home_git_server.sh
    add_remote_on_work.sh
```

## Безопасность
- Syncthing: сквозное шифрование, доступ только между доверенными устройствами.
- Tailscale: приватная сеть, доступ только вашим устройствам; Git‑пользователь без shell.

## Подсказки
- На рабочем ПК может быть запрет на установку ПО. В таком случае используйте портативные версии (Syncthing), или Git через уже установленный SSH.
- Для Syncthing, если прямое соединение не получается, включены реле‑сервера по умолчанию — обычно работает без доп. настроек.