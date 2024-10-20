#!/bin/bash

# Путь к основному скрипту
MAIN_SCRIPT="./script1.sh"

# Путь к папке /log
LOG_DIR="$HOME/log"

# Путь к папке /backup
BACKUP_DIR="$HOME/backup"

# Удаление папок /log и /backup перед началом тестов
rm -rf "$LOG_DIR" "$BACKUP_DIR"

# Функция для генерации тестовых данных
generate_test_data() {
  local dir="$1"
  local size_mb="$2"
  mkdir -p "$dir"
  dd if=/dev/zero of="$dir/test_file" bs=1M count="$size_mb"
}

# Функция для проверки результатов теста
check_test_result() {
  local test_name="$1"
  local expected_output="$2"
  local actual_output="$3"

  if [[ "$actual_output" == *"$expected_output"* ]]; then
    echo "Тест '$test_name' пройден успешно."
  else
    echo "Тест '$test_name' не пройден. Ожидалось: '$expected_output', получено: '$actual_output'."
  fi
}

# Тест 1: Папка /log заполнена менее чем на 70%
echo "Запуск теста 1: Папка /log заполнена менее чем на 70%"
generate_test_data "$LOG_DIR" 512  # Генерируем 512 МБ данных
output=$("$MAIN_SCRIPT" "$LOG_DIR")
expected_output="Заполнение папки '$LOG_DIR': 50%"
check_test_result "Тест 1" "$expected_output" "$output"

# Тест 2: Папка /log заполнена более чем на 70%
echo "Запуск теста 2: Папка /log заполнена более чем на 70%"
generate_test_data "$LOG_DIR" 768 
output=$("$MAIN_SCRIPT" "$LOG_DIR")
expected_output="Папка '$LOG_DIR' заполнена более чем на 70%"
check_test_result "Тест 2" "$expected_output" "$output"

# Тест 3: Папка /log заполнена более чем на 70%, проверка архивирования и удаления файлов
echo "Запуск теста 3: Папка /log заполнена более чем на 70%, проверка архивирования и удаления файлов"
generate_test_data "$LOG_DIR" 768  
output=$("$MAIN_SCRIPT" "$LOG_DIR")
expected_output="Папка '$LOG_DIR' заполнена более чем на 70%"
check_test_result "Тест 3" "$expected_output" "$output"

# Проверка наличия архива и удаленных файлов
if ls "$BACKUP_DIR/backup_"* 1> /dev/null 2>&1; then
  echo "Тест 3: Архив создан успешно."
else
  echo "Тест 3: Ошибка при создании архива."
fi

if [ -z "$(ls -A $LOG_DIR)" ]; then
  echo "Тест 3: Файлы удалены из '$LOG_DIR'."
else
  echo "Тест 3: Ошибка при удалении файлов из '$LOG_DIR'."
fi

# Удаление папок /log и /backup после завершения тестов
rm -rf "$LOG_DIR" "$BACKUP_DIR"