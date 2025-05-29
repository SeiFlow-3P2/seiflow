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
        
        POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        REDIS_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        MONGO_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
        
        sed -i.bak "s/your_secure_password_123/$POSTGRES_PASSWORD/g" .env
        sed -i.bak "s/redis_secure_password_123/$REDIS_PASSWORD/g" .env
        sed -i.bak "s/mongo_secure_password_123/$MONGO_PASSWORD/g" .env
        
        rm .env.bak 2>/dev/null || true
        
        echo "🔐 Сгенерированы безопасные пароли"
        echo "⚠️  Обязательно измените DOMAIN_NAME и SSL_EMAIL в .env файле!"
    else
        echo "✅ .env файл уже существует"
    fi
}

create_directories() {
    echo "📁 Создание необходимых директорий..."
    
    mkdir -p data/{auth_service,payment_service,board_service,calendar_service}/{postgres,redis,mongo}
    mkdir -p data/kafka/{zookeeper/{data,log},broker-1,broker-2,broker-3}
    
    mkdir -p configs/{nginx/{sites-enabled,ssl,logs},ssl/{certs,webroot,letsencrypt}}
    
    mkdir -p logs/{nginx,services}
    
    mkdir -p backups
    
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
    echo "1. Отредактируйте .env файл (установите DOMAIN_NAME и SSL_EMAIL)"
    echo "2. Убедитесь, что все submodules загружены"
    echo "3. Для разработки: make dev"
    echo "4. Для продакшена: make ssl-setup && make up-all"
    echo ""
    echo "📖 Доступные команды:"
    echo "   make help           - показать все команды"
    echo "   make dev            - запустить среду разработки"
    echo "   make up-all         - запустить все сервисы"
    echo "   make monitor        - мониторинг сервисов"
    echo "   make logs           - просмотр логов"
    echo ""
    echo "🌐 После запуска доступно:"
    echo "   Grafana:     http://localhost:3000"
    echo "   Prometheus:  http://localhost:9090"
    echo "   Jaeger:      http://localhost:16686"
    echo "   Kafka UI:    http://localhost:8086"
    echo ""
}

main "$@"