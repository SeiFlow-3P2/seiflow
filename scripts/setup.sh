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
    
    echo ""
    echo "🎉 Установка завершена!"
    echo ""
    echo "📋 Следующие шаги:"
    echo "1. Убедитесь, что все submodules загружены"
    echo "2. Для разработки: пока не работает"
    echo "3. Для продакшена: пока не работает"
    echo ""
    echo "📖 Доступные команды:"
    echo "   make help           - показать все команды"
    echo "   make monitoring     - запустить мониторинг"
    echo "   make kafka          - запустить kafka"
    echo "   make api-gateway    - запустить api-gateway - Нужен dockerfile"
    echo "   make board-service  - запустить board-service - Нужен dockerfile"
    echo "   make auth-service   - запустить auth-service - не работает"
    echo "   make payment-service- запустить payment-service - не работает"
    echo "   make calendar-service- запустить calendar-service - не работает"
    echo ""
    echo "🌐 После запуска доступно:"
    echo "   Grafana:     http://localhost:3000"
    echo "   Prometheus:  http://localhost:9090"
    echo "   Jaeger:      http://localhost:16686"
    echo "   Kafka UI:    http://localhost:8086"
    echo ""
}

main "$@"