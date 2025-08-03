#!/bin/sh

# Скрипт предпросмотра для lf

# Требуемые утилиты:
# - bat: для подсветки синтаксиса
# - file: для определения типа файла
# - atool: для просмотра содержимого архивов
# - mediainfo/exiftool: для метаданных медиафайлов

file="$1"
width="$2"
height="$3"
x="$4"
y="$5"

# Проверяем, существует ли файл
[ ! -f "$file" ] && exit 1

mimetype=$(file --mime-type -b "$file")

case "$mimetype" in
    text/* | application/json)
        # Используем bat для подсветки синтаксиса, если он доступен
        if command -v bat >/dev/null 2>&1; then
            bat --color=always --paging=never --style=plain --terminal-width="$width" "$file"
        else
            # Фоллбэк на cat, если нет bat
            cat "$file"
        fi
        ;;
    image/*)
        # Попробуйте использовать pistol для предпросмотра изображений, если он установлен
        if command -v pistol >/dev/null 2>&1; then
            pistol "$file"
        else
            # Иначе выводим информацию о файле
            mediainfo "$file" || exiftool "$file"
        fi
        ;;
    video/* | audio/*)
        mediainfo "$file" || exiftool "$file"
        ;;
    application/zip | application/x-rar | application/x-7z-compressed)
        atool -l "$file"
        ;;
    *)
        # Для всех остальных файлов просто показываем информацию
        file "$file"
        ;;
esac
