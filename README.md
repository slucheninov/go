# Go Local Install

Script for local installation of Go and golangci-lint without root privileges.

## Structure

```
go/
├── update.sh          # installation script
├── bin/               # symlinks to binaries (add to $PATH)
└── version/           # downloaded archives and extracted versions
```

## Usage

```sh
./update.sh
```

The script:
1. Detects OS and architecture
2. Downloads the Go archive for the specified version (if not already downloaded)
3. Extracts to `version/<VERSION>/`
4. Creates symlinks in `bin/`
5. Installs golangci-lint (if not present)

## PATH setup

```sh
export PATH="$HOME/go/bin:$PATH"
```

## Changing Go version

Edit `VERSION` at the top of `update.sh` and re-run the script.

## Requirements

- curl
- tar
- sh / bash / zsh
- Linux (x86_64, arm64) or macOS (x86_64, arm64)

---

# Go Local Install (UA)

Скрипт для локального встановлення Go та golangci-lint без прав суперкористувача.

## Структура

```
go/
├── update.sh          # скрипт встановлення
├── bin/               # симлінки на бінарники (додати до $PATH)
└── version/           # завантажені архіви та розпаковані версії
```

## Використання

```sh
./update.sh
```

Скрипт:
1. Визначає ОС та архітектуру
2. Завантажує архів Go вказаної версії (якщо ще не завантажений)
3. Розпаковує в `version/<VERSION>/`
4. Створює симлінки в `bin/`
5. Встановлює golangci-lint (якщо відсутній)

## Налаштування PATH

```sh
export PATH="$HOME/go/bin:$PATH"
```

## Зміна версії Go

Відредагувати `VERSION` на початку `update.sh` та перезапустити скрипт.

## Вимоги

- curl
- tar
- sh / bash / zsh
- Linux (x86_64, arm64) або macOS (x86_64, arm64)
