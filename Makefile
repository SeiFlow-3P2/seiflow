.PHONY: help up-auth up-payment up-board up-calendar up-backend up-kafka up-monitoring up-all down logs

# Переменные
ENV_FILE = --env-file .env

help: ## Показать справку
	@echo "Доступные команды:"
	@echo "  up-auth      - Запустить auth сервис с БД"
	@echo "  up-payment   - Запустить payment сервис с БД"
	@echo "  up-board     - Запустить board сервис с БД"
	@echo "  up-calendar  - Запустить calendar сервис с БД"
	@echo "  up-backend   - Запустить все backend сервисы"
	@echo "  up-kafka     - Запустить Kafka"
	@echo "  up-monitoring- Запустить мониторинг"
	@echo "  up-all       - Запустить всё"
	@echo "  down         - Остановить все сервисы"
	@echo "  logs         - Показать логи всех сервисов"
	@echo "  ps           - Показать статус контейнеров"
	@echo "  clean        - Удалить все контейнеры и volumes"

up-auth: ## Запустить auth сервис с БД
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/services/auth-service.yml up -d

up-payment: ## Запустить payment сервис с БД
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/services/payment-service.yml up -d

up-board: ## Запустить board сервис с БД
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/services/board-service.yml up -d

up-api-gateway: ## Запустить api-gateway
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/services/api-gateway.yml up -d

up-calendar: ## Запустить calendar сервис с БД
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/services/calendar-service.yml up -d

up-backend: ## Запустить все backend сервисы
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) \
		-f docker/services/auth-service.yml \
		-f docker/services/payment-service.yml \
		-f docker/services/board-service.yml \
		-f docker/services/calendar-service.yml \
		up -d

up-kafka: ## Запустить Kafka
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/infrastructure/kafka.yml up -d

up-monitoring: ## Запустить мониторинг
	@echo "🚀 Создание общих сетей..."
	docker network create seiflow_backend 2>/dev/null || true
	docker compose $(ENV_FILE) -f docker/infrastructure/monitoring.yml up -d

up-all: ## Запустить всё
	docker compose $(ENV_FILE) up -d

down: ## Остановить все сервисы
	docker compose $(ENV_FILE) down

logs: ## Показать логи всех сервисов
	docker compose $(ENV_FILE) logs -f

logs-auth: ## Логи auth сервиса
	docker compose $(ENV_FILE) -f docker/services/auth-service.yml logs -f auth_service

logs-payment: ## Логи payment сервиса
	docker compose $(ENV_FILE) -f docker/services/payment-service.yml logs -f payment_service

logs-board: ## Логи board сервиса
	docker compose $(ENV_FILE) -f docker/services/board-service.yml logs -f board_service

logs-calendar: ## Логи calendar сервиса
	docker compose $(ENV_FILE) -f docker/services/calendar-service.yml logs -f calendar_service

logs-kafka: ## Логи Kafka
	docker compose $(ENV_FILE) -f docker/infrastructure/kafka.yml logs -f kafka_broker_1

logs-monitoring: ## Логи мониторинга
	cd docker/infrastructure && docker compose $(ENV_FILE) -f monitoring.yml logs -f

ps: ## Показать статус контейнеров
	docker compose $(ENV_FILE) ps

restart: ## Перезапустить все сервисы
	docker compose $(ENV_FILE) restart

clean: ## Удалить все контейнеры и volumes
	docker network rm seiflow_backend 2>/dev/null || true
	docker system prune -f

clean-db: ## Удалить только volumes с базами данных
	@echo "⚠️  Это удалит ВСЕ данные из баз!"
	@read -p "Продолжить? (y/N): " confirm && [ "$confirm" = "y" ]
	docker volume rm \
		seiflow_auth_postgres_data \
		seiflow_payment_postgres_data \
		seiflow_board_mongo_data \
		seiflow_calendar_mongo_data \
		seiflow_auth_redis_data \
		seiflow_payment_redis_data \
		seiflow_board_redis_data \
		seiflow_calendar_redis_data \
		2>/dev/null || true

# Команды для разработки
create-networks: ## Создать общие Docker сети
	@echo "🌐 Создание общих Docker сетей..."
	docker network create seiflow_backend 2>/dev/null || echo "✅ Сеть seiflow_backend уже существует"

dev-setup: ## Настройка окружения для разработки
	@if [ ! -f ".env" ]; then \
		cp .env.example .env; \
		echo "✅ Создан .env файл из .env.example"; \
	fi
	@$(MAKE) create-networks
	@$(MAKE) create-configs
	@echo "✅ Настройка завершена. Теперь можно запускать: make up-all"

health: ## Проверить здоровье всех сервисов
	@echo "Проверка здоровья сервисов..."
	@docker compose $(ENV_FILE) ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"