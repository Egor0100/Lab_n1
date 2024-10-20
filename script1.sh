#!/bin/bash

# Путь к папке
LOG_DIR="$1"

# Проверка, что папка существует и ее создание, если она не существует
if [ ! -d "$LOG_DIR" ]; then #-d directory
  echo "Папка '$LOG_DIR' не существует. Создаю папку."
  LOG_DIR="$HOME/log"
  mkdir -p "$LOG_DIR"
fi

# Лимит заполнения папки в байтах (1 ГБ = 1024 * 1024 * 1024 байт)
LIMIT_BYTES=$((1024 * 1024 * 1024))

# Получение размера папки в килобайтах и преобразование в байты
DIR_SIZE_KB=$(du -sk "$LOG_DIR" | awk '{print $1}') #du - disk usage, -sk размер в килобайтах
DIR_SIZE_BYTES=$((DIR_SIZE_KB * 1024))

# Вычисление заполнения папки в процентах относительно лимита
USAGE_PERCENT=$((DIR_SIZE_BYTES * 100 / LIMIT_BYTES))

# Вывод результата
echo "Заполнение папки '$LOG_DIR': $USAGE_PERCENT%"

# Пороговый процент заполнения
THRESHOLD_PERCENT=70

# Количество файлов для архивации
N=3

# Проверка, нужно ли выполнить архивирование и удаление
if [ "$USAGE_PERCENT" -gt "$THRESHOLD_PERCENT" ]; then # -gt greater than
  echo "Папка '$LOG_DIR' заполнена более чем на $THRESHOLD_PERCENT%"

  # Создание папки /backup, если она не существует
  BACKUP_DIR="$HOME/backup"
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR" #-p Если директория существует, то не выводит ошибку
  fi

  # Получение списка трех файлов в папке /log, отсортированных по дате модификации
  FILES_TO_ARCHIVE=$(find "$LOG_DIR" -maxdepth 1 -type f -exec stat -f "%m %N" {} \; | sort -n | head -n "$N" | awk '{print $2}')

  # Архивирование файлов в /backup
  BACKUP_FILE="$BACKUP_DIR/backup_files.tar.gz"
  tar -czf "$BACKUP_FILE" -C "$LOG_DIR" $(basename -a $FILES_TO_ARCHIVE)

  # Проверка, что архив создан успешно
  if [ $? -eq 0 ]; then # -eq Equal to
    echo "Файлы успешно заархивированы в $BACKUP_FILE"

    # Удаление файлов из /log
    for FILE in $FILES_TO_ARCHIVE; do
      rm -f "$FILE"
    done
    echo "Файлы удалены из '$LOG_DIR'"
  else
    echo "Ошибка при архивировании файлов."
  fi
else
  echo "Папка '$LOG_DIR' не превышает порогового значения заполнения."
fi