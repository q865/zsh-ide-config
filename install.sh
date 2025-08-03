#!/bin/bash
#
# install.sh
#
# Этот скрипт настраивает Zsh IDE на новой системе Arch Linux.
#

set -e # Exit immediately if a command exits with a non-zero status.

# --- Functions ---

# Функция для вывода сообщений
msg() {
    echo -e "\n\e[32m\e[1m>>> $1\e[0m"
}

# Функция для проверки наличия команды
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# --- Main Script ---

# 1. Проверка зависимостей
msg "Проверка зависимостей (git, yay)..."
if ! command_exists git; then
    echo "Ошибка: Git не установлен. Пожалуйста, установите его (sudo pacman -S git)."
    exit 1
fi
if ! command_exists yay; then
    echo "Ошибка: yay не найден. Пожалуйста, установите его."
    exit 1
fi

# 2. Установка пакетов
msg "Установка необходимых пакетов..."
PACKAGES=(
    zsh
    starship
    fzf
    zoxide
    bat
    eza # Используем eza вместо lsd
    neovim
    lazygit
    direnv
    zellij
    lf
    kitty # Добавляем терминал Kitty
)
yay -S --needed --noconfirm "${PACKAGES[@]}"

# 3. Установка Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    msg "Установка Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    msg "Oh My Zsh уже установлен."
fi

# 4. Установка плагинов Zsh
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
msg "Установка плагинов Zsh..."
PLUGINS=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
    "https://github.com/Aloxaf/fzf-tab"
)
for plugin_url in "${PLUGINS[@]}"; do
    plugin_name=$(basename "$plugin_url")
    target_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    if [ ! -d "$target_dir" ]; then
        git clone --depth=1 "$plugin_url" "$target_dir"
    else
        echo "Плагин $plugin_name уже установлен."
    fi
done

# 5. Резервное копирование и создание символических ссылок
msg "Создание символических ссылок для конфигурационных файлов..."
CONFIG_DIR=$(pwd)

# Функция для создания бэкапа и ссылки
backup_and_link() {
    local src=$1
    local dest=$2
    
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "Ссылка для $dest уже существует и указывает на правильный файл."
        return
    fi

    if [ -e "$dest" ]; then
        local backup_path="${dest}.bak.$(date +%Y%m%d%H%M%S)"
        echo "Найден существующий файл $dest. Создается резервная копия: $backup_path"
        mv "$dest" "$backup_path"
    fi
    
    # Создаем директорию, если она не существует
    mkdir -p "$(dirname "$dest")"
    
    echo "Создание ссылки: $dest -> $src"
    ln -sfn "$src" "$dest"
}

backup_and_link "$CONFIG_DIR/.zshrc" "$HOME/.zshrc"
backup_and_link "$CONFIG_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
backup_and_link "$CONFIG_DIR/.config/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
backup_and_link "$CONFIG_DIR/.config/lf/lfrc" "$HOME/.config/lf/lfrc"
backup_and_link "$CONFIG_DIR/.config/lf/pv.sh" "$HOME/.config/lf/pv.sh"

# 6. Настройка Kitty и Zellij Layouts
msg "Настройка терминала Kitty и окружения Zellij..."
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/zellij/layouts"

msg "Загрузка темы Catppuccin Mocha для Kitty..."
curl -s -o "$HOME/.config/kitty/catppuccin-mocha.conf" https://raw.githubusercontent.com/catppuccin/kitty/main/mocha.conf

msg "Создание конфигурационного файла kitty.conf..."
cat <<EOF > "$HOME/.config/kitty/kitty.conf"
# Включаем тему Catppuccin Mocha
@include "catppuccin-mocha.conf"

# Устанавливаем шрифт Nerd Font для иконок
# ВАЖНО: Убедитесь, что "FiraCode Nerd Font Mono" установлен!
font_family      FiraCode Nerd Font Mono
bold_font        auto
italic_font      auto
bold_italic_font auto

# Добавляем отступы для чистого вида
window_padding_width 10
EOF

# Создаем символическую ссылку на layout для Zellij
backup_and_link "$CONFIG_DIR/.config/zellij/layouts/dev-setup.kdl" "$HOME/.config/zellij/layouts/dev-setup.kdl"

# 7. Создание файла для секретов
if [ ! -f "$HOME/.zsh_secrets" ]; then
    msg "Создание файла для секретов ~/.zsh_secrets"
    touch "$HOME/.zsh_secrets"
    echo "# Добавьте сюда ваши секретные переменные, например:" >> "$HOME/.zsh_secrets"
    echo "# export GEMINI_API_KEY='...'" >> "$HOME/.zsh_secrets"
fi

# 8. Смена оболочки по умолчанию на Zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    msg "Попытка сменить оболочку по умолчанию на Zsh. Может потребоваться пароль."
    chsh -s "$(which zsh)"
    if [ $? -eq 0 ]; then
        echo "Оболочка успешно изменена. Пожалуйста, перезапустите систему или терминал."
    else
        echo "Не удалось сменить оболочку. Пожалуйста, сделайте это вручную: chsh -s $(which zsh)"
    fi
else
    msg "Zsh уже является оболочкой по умолчанию."
fi

msg "Установка завершена! Перезапустите терминал, чтобы применить изменения."
