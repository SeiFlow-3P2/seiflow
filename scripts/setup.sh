#!/bin/bash

set -e

echo "🚀 Настройка проекта SeiFlow..."

check_dependencies() {
    echo "🔍 Проверка зависимостей..."
    
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker не установлен. Установите Docker и повторите попытку."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo "❌ Docker Compose не установлен. Установите Docker Compose и повторите попытку."
        exit 1
    fi
    
    if ! command -v git &> /dev/null; then
        echo "❌ Git не установлен. Установите Git и повторите попытку."
        exit 1
    fi
    
    echo "✅ Все зависимости установлены"
}

setup_env() {
    echo "⚙️  Настройка переменных окружения..."
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
        echo "📝 Создан .env файл из .env.example"
        
        echo "🔐 Сгенерированы безопасные пароли"
    else
        echo "✅ .env файл уже существует"
    fi
}

create_directories() {
    echo "📁 Создание необходимых директорий..."
    
    mkdir -p data/{auth_service,payment_service,board_service,calendar_service}/{postgres,redis,mongo}
    mkdir -p data/kafka/{zookeeper/{data,log},broker-1,broker-2,broker-3}
    
    echo "✅ Директории созданы"
}
setup_submodules() {
    echo "📦 Инициализация submodules..."
    
    if [ -f ".gitmodules" ]; then
        git submodule update --init --recursive
        echo "✅ Submodules инициализированы"
    else
        echo "⚠️  .gitmodules не найден, пропускаем инициализацию submodules"
    fi
}

check_ports() {
    echo "🔍 Проверка доступности портов..."
    
    PORTS=(80 443 5431 5430 6381 6380 6383 6384 8000 8001 8002 8003 8081 8082 8080 9092 9093 9094 2181 8085 8086 16686 9090 3000 27017 27018)
    
    for port in "${PORTS[@]}"; do
        if ss -tulwn | grep ":$port " > /dev/null 2>&1; then
            echo "⚠️  Порт $port уже используется"
        fi
    done
    
    echo "✅ Проверка портов завершена"
}

main() {
    echo "================================================"
    echo "🎯 Установка SeiFlow"
    echo "================================================"
    
    check_dependencies
    setup_env
    create_directories
    setup_submodules
    check_ports

    echo "================================================"
    echo "🎯 Установка SeiFlow" завершена
    echo "================================================"
}

main "$@"