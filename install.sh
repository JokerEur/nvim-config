#!/usr/bin/env bash
#
# install.sh — установка всех зависимостей для этого Neovim-конфига.
# Поддерживаемые системы: macOS (Homebrew) и Arch Linux (pacman).
#
# Использование:
#   ./install.sh            # поставить всё + синхронизировать плагины
#   ./install.sh --no-sync  # только системные пакеты, без запуска nvim
#
set -euo pipefail

# ── Цветной вывод ───────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'; RED=$'\033[31m'; GREEN=$'\033[32m'
  YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=''; RED=''; GREEN=''; YELLOW=''; BLUE=''; RESET=''
fi

info()  { echo "${BLUE}${BOLD}==>${RESET} ${BOLD}$*${RESET}"; }
ok()    { echo "${GREEN}  ✓${RESET} $*"; }
warn()  { echo "${YELLOW}  !${RESET} $*"; }
err()   { echo "${RED}  ✗${RESET} $*" >&2; }

DO_SYNC=1
for arg in "$@"; do
  case "$arg" in
    --no-sync) DO_SYNC=0 ;;
    -h|--help)
      grep -E '^#( |$)' "$0" | sed -E 's/^# ?//'
      exit 0 ;;
    *) err "Неизвестный аргумент: $arg"; exit 1 ;;
  esac
done

# ── Определение ОС ───────────────────────────────────────────────────────────
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if [[ -f /etc/arch-release ]] || grep -qi '^ID=arch' /etc/os-release 2>/dev/null \
         || grep -qi 'arch' /etc/os-release 2>/dev/null; then
        echo "arch"
      else
        echo "linux-other"
      fi ;;
    *) echo "unknown" ;;
  esac
}

OS="$(detect_os)"
info "Обнаружена система: ${BOLD}${OS}${RESET}"

# =============================================================================
# macOS
# =============================================================================
install_macos() {
  # Command Line Tools (компилятор C/clang, make) — нужны для treesitter и
  # telescope-fzf-native (build = "make").
  if ! xcode-select -p >/dev/null 2>&1; then
    info "Устанавливаю Xcode Command Line Tools (нужны clang/make)…"
    xcode-select --install || true
    warn "Дождитесь окончания установки Command Line Tools и запустите скрипт снова."
    warn "Если установка уже завершилась — просто продолжайте."
  else
    ok "Xcode Command Line Tools уже установлены"
  fi

  # Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    info "Устанавливаю Homebrew…"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Подхватываем brew в текущую сессию (Apple Silicon / Intel)
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    ok "Homebrew уже установлен"
  fi

  # brew-формулы. Mason сам скачает LSP-серверы, но ему нужны node/python/go/rust,
  # а также распаковщики (unzip идёт из системы).
  local formulae=(
    neovim          # сам редактор (нужен >= 0.11 для нативного LSP API)
    git
    ripgrep         # telescope live_grep  (rg)
    fd              # telescope find_files (fd)
    node            # LSP-серверы (ts_ls, html, cssls), markdown-preview, js-debug
    python          # pyright, debugpy
    go              # gopls, delve
    rust            # rust-analyzer, codelldb, cargo, clippy
    cmake           # cmake LSP + сборка некоторых пакетов
    make            # telescope-fzf-native, treesitter
    wget curl unzip # Mason скачивает и распаковывает бинарники
    lazygit         # опционально, удобно для git-плагинов
  )

  info "Устанавливаю пакеты через Homebrew…"
  brew install "${formulae[@]}" || warn "Некоторые формулы могли уже стоять — это ок."

  # Nerd Font для иконок (devicons / lualine / neo-tree).
  info "Устанавливаю Nerd Font (JetBrainsMono)…"
  brew install --cask font-jetbrains-mono-nerd-font \
    || warn "Не удалось поставить шрифт (возможно, уже установлен)."
}

# =============================================================================
# Arch Linux
# =============================================================================
install_arch() {
  local SUDO=""
  [[ $EUID -ne 0 ]] && SUDO="sudo"

  info "Обновляю базы пакетов pacman…"
  $SUDO pacman -Sy --noconfirm

  # base-devel даёт gcc/make и всё для сборки (treesitter, fzf-native).
  local pkgs=(
    neovim
    git
    base-devel      # gcc, make — компиляция парсеров и fzf-native
    ripgrep         # telescope live_grep
    fd              # telescope find_files
    nodejs npm      # LSP-серверы, markdown-preview, js-debug
    python python-pip
    go              # gopls, delve
    rust            # rust-analyzer, cargo, clippy
    cmake
    wget curl unzip # Mason
    wl-clipboard    # системный буфер обмена (unnamedplus) в Wayland
    xclip           # то же для X11
    ttf-jetbrains-mono-nerd-font  # иконки
  )

  info "Устанавливаю пакеты через pacman…"
  $SUDO pacman -S --needed --noconfirm "${pkgs[@]}" \
    || warn "Часть пакетов могла уже стоять — это ок."
}

# ── Выбор ветки ──────────────────────────────────────────────────────────────
case "$OS" in
  macos) install_macos ;;
  arch)  install_arch ;;
  linux-other)
    err "Похоже, это Linux, но не Arch."
    err "Установите вручную: neovim git ripgrep fd nodejs npm python python-pip go rust cmake gcc make unzip curl wget + Nerd Font."
    exit 1 ;;
  *)
    err "Неподдерживаемая ОС. Скрипт работает только на macOS и Arch Linux."
    exit 1 ;;
esac

# ── Проверка ключевых бинарников ────────────────────────────────────────────
info "Проверяю наличие ключевых инструментов…"
check() {
  if command -v "$1" >/dev/null 2>&1; then
    ok "$1 → $(command -v "$1")"
  else
    warn "$1 не найден в PATH"
  fi
}
for bin in nvim git rg fd node npm python3 go cargo cc make unzip curl; do
  check "$bin"
done

# ── Синхронизация плагинов и Mason-пакетов ──────────────────────────────────
if [[ "$DO_SYNC" -eq 1 ]]; then
  info "Синхронизирую плагины (lazy.nvim) — первый запуск может занять пару минут…"
  nvim --headless "+Lazy! sync" +qa || warn "Lazy sync завершился с предупреждениями."

  info "Устанавливаю treesitter-парсеры…"
  nvim --headless "+TSUpdateSync" +qa || warn "TSUpdate завершился с предупреждениями."

  info "Ставлю LSP-серверы и debug-адаптеры через Mason…"
  nvim --headless \
    "+MasonInstall lua-language-server rust-analyzer clangd pyright gopls typescript-language-server html-lsp css-lsp debugpy delve codelldb js-debug-adapter" \
    +qa || warn "Часть Mason-пакетов могла не установиться — доустановите через :Mason."
else
  warn "Флаг --no-sync: пропускаю синхронизацию плагинов. Запустите nvim вручную."
fi

echo
info "${GREEN}Готово!${RESET} Запустите ${BOLD}nvim${RESET} — при первом старте плагины дозагрузятся автоматически."
warn "Не забудьте выбрать Nerd Font (JetBrainsMono) в настройках терминала, иначе иконки будут «квадратиками»."
