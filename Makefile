.PHONY: help up down ps logs clean

# Цвета для красивого вывода
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

# Переменные
COMPOSE_CMD = docker compose --env-file .env
NETWORK_NAME = seiflow_backend

help: ## Показать эту справку
	@echo "$(GREEN)Доступные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

# === УПРАВЛЕНИЕ СЕТЬЮ ===
network: ## Создать общую сеть
	@docker network create $(NETWORK_NAME) 2>/dev/null || echo "$(YELLOW)Сеть $(NETWORK_NAME) уже существует$(NC)"

# === ЗАПУСК СЕРВИСОВ ===
auth: network ## Запустить Auth сервис
	@echo "$(GREEN)🚀 Запускаю Auth сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml up -d
	@echo "$(GREEN)✅ Auth сервис запущен$(NC)"

payment: network ## Запустить Payment сервис
	@echo "$(GREEN)🚀 Запускаю Payment сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/payment-service.yml up -d
	@echo "$(GREEN)✅ Payment сервис запущен$(NC)"

board: network ## Запустить Board сервис
	@echo "$(GREEN)🚀 Запускаю Board сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/board-service.yml up -d
	@echo "$(GREEN)✅ Board сервис запущен$(NC)"

calendar: network ## Запустить Calendar сервис
	@echo "$(GREEN)🚀 Запускаю Calendar сервис...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/calendar-service.yml up -d
	@echo "$(GREEN)✅ Calendar сервис запущен$(NC)"

gateway: network ## Запустить API Gateway
	@echo "$(GREEN)🚀 Запускаю API Gateway...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/api-gateway.yml up -d
	@echo "$(GREEN)✅ API Gateway запущен$(NC)"

kafka: network ## Запустить Kafka
	@echo "$(GREEN)🚀 Запускаю Kafka...$(NC)"
	@$(COMPOSE_CMD) -f docker/infrastructure/kafka.yml up -d
	@echo "$(GREEN)✅ Kafka запущена$(NC)"

monitoring: network ## Запустить мониторинг
	@echo "$(GREEN)🚀 Запускаю мониторинг...$(NC)"
	@$(COMPOSE_CMD) -f docker/infrastructure/monitoring.yml up -d
	@echo "$(GREEN)✅ Мониторинг запущен$(NC)"

# === ЗАПУСК ВСЕГО ===
up: network ## Запустить все сервисы
	@echo "$(GREEN)🚀 Запускаю все сервисы...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml \
		-f docker/services/payment-service.yml \
		-f docker/services/board-service.yml \
		-f docker/services/calendar-service.yml \
		-f docker/services/api-gateway.yml \
		-f docker/infrastructure/kafka.yml \
		-f docker/infrastructure/monitoring.yml \
		up -d
	@echo "$(GREEN)✅ Все сервисы запущены!$(NC)"
	@echo ""
	@echo "$(YELLOW)📋 Доступные URL:$(NC)"
	@echo "  • API Gateway:     http://localhost:8080"
	@echo "  • Kafka UI:        http://localhost:8086"
	@echo "  • Board Mongo:     http://localhost:8081"
	@echo "  • Calendar Mongo:  http://localhost:8083"
	@echo "  • Grafana:         http://localhost:3000"
	@echo "  • Prometheus:      http://localhost:9090"
	@echo "  • Jaeger:          http://localhost:16686"

# === ОСТАНОВКА СЕРВИСОВ ===
down: ## Остановить все сервисы
	@echo "$(RED)⏹️  Останавливаю все сервисы...$(NC)"
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml \
		-f docker/services/payment-service.yml \
		-f docker/services/board-service.yml \
		-f docker/services/calendar-service.yml \
		-f docker/services/api-gateway.yml \
		-f docker/infrastructure/kafka.yml \
		-f docker/infrastructure/monitoring.yml \
		down
	@echo "$(GREEN)✅ Все сервисы остановлены$(NC)"

# === СТАТУС И ЛОГИ ===
ps: ## Показать статус контейнеров
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

logs: ## Показать логи всех сервисов
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml \
		-f docker/services/payment-service.yml \
		-f docker/services/board-service.yml \
		-f docker/services/calendar-service.yml \
		-f docker/services/api-gateway.yml \
		logs -f

logs-auth: ## Логи Auth сервиса
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml logs -f

logs-payment: ## Логи Payment сервиса
	@$(COMPOSE_CMD) -f docker/services/payment-service.yml logs -f

logs-board: ## Логи Board сервиса
	@$(COMPOSE_CMD) -f docker/services/board-service.yml logs -f

logs-calendar: ## Логи Calendar сервиса
	@$(COMPOSE_CMD) -f docker/services/calendar-service.yml logs -f

logs-gateway: ## Логи API Gateway
	@$(COMPOSE_CMD) -f docker/services/api-gateway.yml logs -f

# === ОЧИСТКА ===
clean: ## Удалить все контейнеры и volumes
	@echo "$(RED)🗑️  Удаляю все контейнеры и данные...$(NC)"
	@docker compose down -v --remove-orphans
	@docker network rm $(NETWORK_NAME) 2>/dev/null || true
	@echo "$(GREEN)✅ Очистка завершена$(NC)"

restart: down up ## Перезапустить все сервисы

# === БЫСТРЫЕ КОМАНДЫ ===
dev: auth board calendar payment gateway ## Запустить только сервисы (без kafka и мониторинга)
	@echo "$(GREEN)✅ Сервисы для разработки запущены$(NC)"

stop-auth: ## Остановить Auth сервис
	@$(COMPOSE_CMD) -f docker/services/auth-service.yml down

stop-payment: ## Остановить Payment сервис
	@$(COMPOSE_CMD) -f docker/services/payment-service.yml down

stop-board: ## Остановить Board сервис
	@$(COMPOSE_CMD) -f docker/services/board-service.yml down

stop-calendar: ## Остановить Calendar сервис
	@$(COMPOSE_CMD) -f docker/services/calendar-service.yml down

# === ПРОВЕРКА ЗДОРОВЬЯ ===
health: ## Проверить здоровье сервисов
	@echo "$(YELLOW)🏥 Проверка здоровья сервисов...$(NC)"
	@echo ""
	@docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(auth|payment|board|calendar|gateway)" || echo "$(RED)Сервисы не запущены$(NC)"

# === ИНИЦИАЛИЗАЦИЯ ===
init: ## Первичная настройка проекта
	@echo "$(GREEN)🔧 Инициализация проекта...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN)✅ Создан файл .env$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Файл .env уже существует$(NC)"; \
	fi
	@$(MAKE) network
	@echo "$(GREEN)✅ Проект готов к работе!$(NC)"
	@echo "$(YELLOW)Используйте 'make up' для запуска всех сервисов$(NC)"