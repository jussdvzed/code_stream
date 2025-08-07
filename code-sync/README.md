# Code Sync Toolkit (без установки на рабочем ПК)

Синхронизация/доступ к коду между домом и работой без установки ПО и без sudo на рабочем ПК.

- Вариант A (нулевая установка на работе — рекомендуется): удалённый IDE в браузере.
  - Дома поднимаем `code-server` (VS Code в браузере) и публикуем через обратный SSH‑туннель (`localhost.run`).
  - На работе: открываете выданный URL в браузере, редактируете код удалённо.
- Вариант B: P2P‑синк (Syncthing portable) без sudo.
  - Запуск бинарника Syncthing из домашней папки пользователя на обоих ПК. Никаких системных установок.

## Вариант A: Удалённый IDE через браузер (code-server + SSH tunnel)

Ничего не требуется на рабочем ПК, кроме браузера.

### Шаг 1. Домашний ПК — установка code-server (без sudo)
```bash
chmod +x remote-ide/install_code_server_home.sh
./remote-ide/install_code_server_home.sh
```
Скрипт поставит `code-server` в `~/.local` и создаст конфиг с паролем. Пароль выведется в консоль.

Запуск IDE:
```bash
~/.local/bin/code-server
# Откройте локально: http://127.0.0.1:8080 (для проверки)
```

### Шаг 2. Домашний ПК — открыть публичный URL через обратный туннель
```bash
chmod +x remote-ide/start_tunnel_localhostrun.sh
./remote-ide/start_tunnel_localhostrun.sh
```
Скрипт создаст публичный URL вида `https://xxxxx.lhr.life` (или схожий), выводит его в консоль.

### Шаг 3. Рабочий ПК — просто открыть URL в браузере
- Введите пароль от `code-server` (из шага 1).
- Работаете как в VS Code, файлы остаются дома.

Примечания:
- Никаких установок/админ‑прав на работе.
- Для постоянной работы можно держать оба процесса запущенными (IDE + SSH туннель). При разрыве интернет‑соединения перезапустите туннель.
- Альтернативы для туннеля: `serveo.net`, свой VPS с `ssh -R`, `cloudflared` (при желании).

## Вариант B: Syncthing portable (без sudo)

Позволяет синхронизировать папки локально на обоих ПК без установки в систему.

### Установка/запуск (оба ПК)
```bash
chmod +x syncthing/install_syncthing_user.sh
./syncthing/install_syncthing_user.sh

# Запуск в фоне (user):
./syncthing/run_user.sh
```
Web UI: http://127.0.0.1:8384

### Настройка папки
1. Создайте папку для синка, например `~/code-sync`:
   ```bash
   mkdir -p "$HOME/code-sync"
   ```
2. В Web UI на домашнем ПК добавьте папку `~/code-sync`, включите версионность по вкусу.
3. Скопируйте Device ID второго ПК, обменяйтесь устройствами и папкой, примите приглашение.

Примечания:
- Не требует sudo. Бинарник лежит в `~/.local/bin/syncthing`.
- Опционально добавьте автозапуск через `systemd --user`, если доступно; либо используйте `run_user.sh`.

## Структура
```
code-sync/
  README.md
  remote-ide/
    install_code_server_home.sh
    start_tunnel_localhostrun.sh
  syncthing/
    install_syncthing_user.sh
    run_user.sh
  # предыдущие файлы оставлены для совместимости:
  syncthing/install_syncthing_linux.sh
  syncthing/syncthing_service_enable.sh
  tailscale/install_tailscale_linux.sh
  git/setup_home_git_server.sh
  git/add_remote_on_work.sh
```

## Безопасность
- Удалённый IDE: защищён паролем, URL не публично известен. Для большего уровня — включайте авторизацию по токенам/прокси/Zero Trust.
- Syncthing: сквозное шифрование между доверенными устройствами.